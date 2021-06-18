
import yargs from "yargs";

// -- Process input parameters

let { radius, calculation } = yargs.argv;

console.log( { radius, calculation } );

radius = parseFloat( radius );

if( typeof radius !== "number" )
{
  throw new Error("Missing or invalid parameter [radius]");
}

if( typeof calculation !== "string" )
{
  throw new Error("Missing or invalid parameter [calculation]");
}

// -- Calculation

if( calculation === "surface" )
{
  const surface = Math.PI * radius * radius;

  console.log(
    `The surface of a circle with radius [${radius}] is [${surface}]`);
}
else if( calculation === "circumfence" )
{
  const circumfence = 2 * Math.PI * radius;

  console.log(
    `The circumfence of a circle with radius [${radius}] is [${circumfence}]`);
}
else {
  throw new Error(`Invalid value for parameter [calculation=${calculation}]`);
}
