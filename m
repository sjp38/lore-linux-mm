Date: Thu, 25 Jul 2002 06:15:52 +0100
From: John Levon <levon@movementarian.org>
Subject: Re: page_add/remove_rmap costs
Message-ID: <20020725051552.GA48429@compsoc.man.ac.uk>
References: <3D3E4A30.8A108B45@zip.com.au> <20020725045040.GD2907@holomorphy.com> <3D3F893D.4074CDE5@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D3F893D.4074CDE5@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2002 at 10:14:37PM -0700, Andrew Morton wrote:

> > c0135667 1095488  16.8865     .text.lock.page_alloc   /boot/vmlinux-2.5.28-3
> 
> zone->lock?

I wrote a patch some time ago to remove all this guesswork on lock call
sites :

http://marc.theaimsgroup.com/?l=linux-kernel&m=101586797421268&w=2

It seemed to work quite well with my limited testing on my 2-way ...
(pity it macrofies stuff)

> > c0112a84 213189   3.28622     load_balance            /boot/vmlinux-2.5.28-3
> 
> I thought you'd disabled this?

Maybe wli used "op_session", and this was from a previous run. oprofile
< 0.3 had a bug where the vmlinux samples file wasn't moved.

regards
john

-- 
"Hungarian notation is the tactical nuclear weapon of source code obfuscation
techniques." 
	- Roedy Green 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
