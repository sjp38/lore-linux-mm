Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E07BC6B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 16:53:49 -0400 (EDT)
Date: Wed, 12 Aug 2009 21:53:25 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: vma_merge issue
In-Reply-To: <Pine.LNX.4.64.0908122038360.18426@sister.anvils>
Message-ID: <Pine.LNX.4.64.0908122143020.20776@sister.anvils>
References: <a1b36c3a0908101347t796dedbat2ecb0535c32f325b@mail.gmail.com>
 <Pine.LNX.4.64.0908121841550.14314@sister.anvils>
 <a1b36c3a0908121204q1b59df1fk86afec9d05ec16dc@mail.gmail.com>
 <Pine.LNX.4.64.0908122038360.18426@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bill Speirs <bill.speirs@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Aug 2009, Hugh Dickins wrote:
> 
> Don't use anonymous memory, have a 1GB sparse file to back this,
> and mmap it MAP_SHARED, then you won't get charged for RAM+swap.

A "refinement" to that suggestion is to put the file on tmpfs:
you will then get charged for RAM+swap as you use it, but you can
use madvise MADV_REMOVE to unmap pages, punching holes in the file,
freeing up those charges.  A little baroque, but I think it does
amount to a way of doing exactly what you wanted in the first place.

(Note: we do insist on PROT_WRITE access at the time of MADV_REMOVE:
I've even a feeling it was me who insisted on that.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
