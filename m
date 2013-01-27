Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 52BDE6B0005
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 02:16:22 -0500 (EST)
Date: Sat, 26 Jan 2013 23:16:13 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: block: optionally snapshot page contents to provide stable pages
 during write
Message-ID: <20130127071613.GA4761@blackbox.djwong.org>
References: <CA+icZUXsi0jZZE9HBWG0D6-+oJBeX+8nHpZ9F02x=B7dG3X+yg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+icZUXsi0jZZE9HBWG0D6-+oJBeX+8nHpZ9F02x=B7dG3X+yg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>

On Sat, Jan 26, 2013 at 01:39:46PM +0100, Sedat Dilek wrote:
> Hi Darrick,
> 
> can you tell me why you do not put your help text where it normally
> belongs ("help" Kconfig item)?

Sure -- the non-ISA bounce pool is only used by a small number of specific
parts of the kernel that require it.  If those parts aren't built, then forcing
it on causes a useless memory pool to be created, wasting memory.  Since kbuild
can figure out when we need it and when we don't, there's no need to present
the user with a config option that they can only use to do the wrong thing.

--D
> 
> 273 # We also use the bounce pool to provide stable page writes for jbd.  jbd
> 274 # initiates buffer writeback without locking the page or setting
> PG_writeback,
> 275 # and fixing that behavior (a second time; jbd2 doesn't have this
> problem) is
> 276 # a major rework effort.  Instead, use the bounce buffer to snapshot pages
> 277 # (until jbd goes away).  The only jbd user is ext3.
> 278 config NEED_BOUNCE_POOL
> 279         bool
> 280         default y if (TILE && USB_OHCI_HCD) || (BLK_DEV_INTEGRITY && JBD)
> 281         help
> 282         line #273..277
> 
> Noticed while hunting a culprit commit in Linux-Next as my
> kernel-config got changed between next-20130123..next-20130124.
> 
> Regards,
> - Sedat -
> 
> [1] http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=3f1c22e#patch5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
