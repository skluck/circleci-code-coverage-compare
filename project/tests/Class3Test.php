<?php

namespace SKluck\CircleCoverage;

use PHPUnit\Framework\TestCase;

class Class3Test extends TestCase
{
    public function testOne()
    {
        $this->assertSame(1, (new Class3)->one());
    }

    public function testTwo()
    {
        $this->assertSame(2, (new Class3)->two());
    }

    public function testThree()
    {
        $this->assertSame(3, (new Class3)->three());
    }
}
