Date: Wed, 24 Jul 2002 22:42:03 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page_add/remove_rmap costs
Message-ID: <20020725054203.GG2907@holomorphy.com>
References: <3D3E4A30.8A108B45@zip.com.au> <20020725045040.GD2907@holomorphy.com> <3D3F893D.4074CDE5@zip.com.au> <20020725051552.GA48429@compsoc.man.ac.uk> <3D3F9103.FFC79916@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D3F9103.FFC79916@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: John Levon <levon@movementarian.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

John Levon wrote:
>> I wrote a patch some time ago to remove all this guesswork on lock call
>> sites :
>> 

On Wed, Jul 24, 2002 at 10:47:47PM -0700, Andrew Morton wrote:
> Me too, but I just killed all the out-of-line gunk, so the cost
> is shown at the actual callsite.

It will be applied shortly. I've also been building with -g, so addr2line
will resolve the rest given appropriate dumping formats.

What's the op_time / oprofpp command that gives per-EIP sample frequencies?


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
