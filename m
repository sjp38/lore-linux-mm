Date: Wed, 7 May 2003 07:41:00 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
Message-ID: <20030507144100.GD8978@holomorphy.com>
References: <3EB8DBA0.7020305@aitel.hist.no> <1052304024.9817.3.camel@rth.ninka.net> <3EB8E4CC.8010409@aitel.hist.no> <20030507.025626.10317747.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030507.025626.10317747.davem@redhat.com>
Sender: owner-linux-mm@kvack.org
From: Helge Hafting <helgehaf@aitel.hist.no>
Date: Wed, 07 May 2003 12:49:48 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: helgehaf@aitel.hist.no, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

>    No, I compile everything into a monolithic kernel.
>    I don't even enable module support.

On Wed, May 07, 2003 at 02:56:26AM -0700, David S. Miller wrote:
> Andrew, color me stumped.  mm2/linux.patch doesn't have anything
> really interesting in the networking.  Maybe it's something in
> the SLAB and/or pgd/pmg re-slabification changes?

The i810 bits would be a failure case of the original slabification.
At first glance the re-slabification doesn't seem to conflict with the
unmapping-based slab poisoning.

In another thread, you mentioned that a certain netfilter cset had
issues; I think it might be good to add that as a second possible cause.

I'm trying to track down testers with i810's to reproduce the issue,
but the usual suspects and helpers aren't awake yet (most/all of my
target systems are headless, though I regularly abuse my laptop, which
appears to S3/Savage -based and so isn't useful for this).

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
