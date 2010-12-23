Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 634B96B0088
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 16:38:49 -0500 (EST)
Date: Thu, 23 Dec 2010 13:37:09 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Cross compilers (Was: Re: [PATCH] Fix unconditional GFP_KERNEL
 allocations in __vmalloc().)
Message-Id: <20101223133709.d5973e48.randy.dunlap@oracle.com>
In-Reply-To: <20101215144835.adf2078f.sfr@canb.auug.org.au>
References: <1292381126-5710-1-git-send-email-ricardo.correia@oracle.com>
	<1292381600.2994.6.camel@oralap>
	<20101215144835.adf2078f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: "Ricardo M. Correia" <ricardo.correia@oracle.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, andreas.dilger@oracle.com, behlendorf1@llnl.gov, tony@bakeyournoodle.com
List-ID: <linux-mm.kvack.org>

On Wed, 15 Dec 2010 14:48:35 +1100 Stephen Rothwell wrote:

> Hi Ricardo,
> 
> On Wed, 15 Dec 2010 03:53:20 +0100 "Ricardo M. Correia" <ricardo.correia@oracle.com> wrote:
> >
> > Since I have done all these changes manually and I don't have any
> > non-x86-64 machines, it's possible that I may have typoed or missed
> > something and that this patch may break compilation on other
> > architectures or with other config options.
> > 
> > Any suggestions are welcome.
> 
> See http://kernel.org/pub/tools/crosstool/files/bin


OK, what am I doing wrong?

Using alpha or s390x gcc builds on x86_64 host give me:

/local/cross/gcc-4.5.1-nolibc/s390x-linux/bin/s390x-linux-gcc: /lib64/libc.so.6: version `GLIBC_2.11' not found (required by /local/cross/gcc-4.5.1-nolibc/s390x-linux/bin/s390x-linux-gcc)

or

/local/cross/gcc-4.5.1-nolibc/alpha-linux/bin/alpha-linux-gcc: /lib64/libc.so.6: version `GLIBC_2.11' not found (required by /local/cross/gcc-4.5.1-nolibc/alpha-linux/bin/alpha-linux-gcc)


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
desserts:  http://www.xenotime.net/linux/recipes/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
