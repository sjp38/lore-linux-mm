Received: from bix (build.pdx.osdl.net [172.20.1.2])
	by mail.osdl.org (8.11.6/8.11.6) with SMTP id i4NAbfr10765
	for <linux-mm@kvack.org>; Sun, 23 May 2004 03:37:41 -0700
Date: Sun, 23 May 2004 03:37:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Fw: Re: current -linus tree dies on x86_64
Message-Id: <20040523033711.3c641c83.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hmm, for some reason linux-mm keeps on rejecting this email.  Maybe
it's too big (22k!)

Begin forwarded message:

Date: Sun, 23 May 2004 01:21:49 -0700
From: Andrew Morton <akpm@osdl.org>
To: ak@muc.de, linux-mm@kvack.org
Subject: Re: current -linus tree dies on x86_64


Andrew Morton <akpm@osdl.org> wrote:
>
> Andrew Morton <akpm@osdl.org> wrote:
>  >
>  > As soon as I put in enough memory pressure to start swapping it oopses in
>  >  release_pages().
> 
>  I'm doing the bsearch on this.

The crash is caused by the below changeset.  I was using my own .config so
the defconfig update is not the cause.  I guess either the pageattr.c
changes or the instruction replacements.  The lesson here is to split dem
patches up a bit!

Anyway.  Over to you, Andi.




# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/15 10:40:53-07:00 ak@muc.de 
#   [PATCH] x86-64 updates
#   
#   Various accumulated x86-64 patches and bug fixes.
#   
#   It fixes one nasty bug that has been there since NX is used by 
#   default in the kernel. With heavy AGP memory allocation it would
#   set NX on parts of the kernel mapping in some corner cases, which gave
#   endless crash loops. Thanks goes to some wizards in AMD debug labs
#   for getting a trace out of this.
#   
#   Also various other fixes. This patches only changes x86-64 specific
#   files, i have some changes outside too that I am sending separately.
#   
#    - Fix help test for CONFIG_NUMA
#    - Don't enable SMT nice on CMP
#    - Move HT and MWAIT checks up to generic code
#    - Update defconfig
#    - Remove duplicated includes (Arthur Othieno)
#    - Set up GSI entry for ACPI SCI correctly (from i386)
#    - Fix some comments
#    - Fix threadinfo printing in oopses
#    - Set task alignment to 16 bytes
#    - Handle NX bit for code pages correctly in change_page_attr()
#    - Use generic nops for non amd specific kernel
#    - Add __KERNEL__ checks in unistd.h (David Lee)
# 

<patch removed>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
