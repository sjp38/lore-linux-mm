Date: Sat, 4 May 2002 01:39:38 +0200
From: Dave Jones <davej@suse.de>
Subject: Re: page-flags.h
Message-ID: <20020504013938.G30500@suse.de>
References: <20020501192737.R29327@suse.de> <20020501200452.S29327@suse.de> <3CD1FB78.B3314F4B@zip.com.au> <200205032241.g43MfC39082721@smtpzilla1.xs4all.nl> <3CD317DD.2C9FBD11@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3CD317DD.2C9FBD11@zip.com.au>; from akpm@zip.com.au on Fri, May 03, 2002 at 04:06:05PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: ekonijn@xs4all.nl, Christoph Hellwig <hch@infradead.org>, kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 03, 2002 at 04:06:05PM -0700, Andrew Morton wrote:
 > Part of my uncertainty here is that we just don't seem to
 > have a "plan".  Is the objective to completely flatten
 > the include heirarchy, no nested includes, and make all
 > .c files include all headers to which they (and their included
 > headers) refer?
 > 
 > That's pretty aggressive, but I think it's the only sane
 > objective.

<linux/fs.h>, <linux/mm.h>, <linux/sched.h>, <linux/pagemap.h>
are usually the main culprits. Each of these suckers pulls in
dozens and dozens of includes.

So every time someone wants for eg, something trivial like
jiffies, they end up pulling in crap like <asm/mmx.h>
It's hurrendous how much stuff we have in some of the above
mentioned files which probably deserves their own files.

Updated graphs of these dependancies just went up to
ftp://ftp.kernel.org/pub/linux/kernel/people/davej/misc/graphs/

(old versions are in the parent dir before/after the last crapectomy)

    Dave.

-- 
| Dave Jones.        http://www.codemonkey.org.uk
| SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
