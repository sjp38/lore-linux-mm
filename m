Date: Tue, 3 Sep 2002 19:54:38 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.33-mm1
Message-ID: <20020904025438.GV888@holomorphy.com>
References: <3D7437AC.74EAE22B@zip.com.au> <3D755E2D.7A6D55C6@zip.com.au> <20020904011503.GT888@holomorphy.com> <200209032255.43198.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <200209032255.43198.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Andrew Morton <akpm@zip.com.au>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On September 3, 2002 09:15 pm, William Lee Irwin III wrote:
>> William Lee Irwin III <wli@holomorphy.com>
[something must have gotten snipped]

On Tue, Sep 03, 2002 at 10:55:43PM -0400, Ed Tomlinson wrote:
> What are the numbers telling you?  Is you test faster or slower
> with slablru?  Does it page more or less?  Is looking at the number
> of objects the way to determine if slablru is helping?  I submit
> the paging and runtimes are much better indications?  What do
> story do they tell?

Everything else is pretty much fine-tuning. Prior to this there was
zero control exerted over the things. Now it's much better behaved
with far less "swapping while buttloads of instantly reclaimable slab
memory is available" going on. Almost no swapping out of user memory
in favor of bloated slabs.

It's really that binary distinction that's most visible.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
