Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB806B005D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 12:56:44 -0400 (EDT)
Date: Wed, 6 May 2009 17:57:14 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
In-Reply-To: <20090506164945.GD15712@x200.localdomain>
Message-ID: <Pine.LNX.4.64.0905061754250.7350@blonde.anvils>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com>
 <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com>
 <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
 <20090506133434.GX16078@random.random> <4A019719.7030504@redhat.com>
 <Pine.LNX.4.64.0905061739540.5934@blonde.anvils> <20090506164945.GD15712@x200.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Chris Wright wrote:
> 
> I like merge.  For madvise() approach I had used:
> 
> +#define MADV_SHAREABLE 12              /* can share identical pages */
> +#define MADV_UNSHAREABLE 13            /* can not share identical pages */
> 
> But those are maybe better put as MADV_(UN)MERGEABLE
> (gets a bit confusing when you talk of merging vmas ;-)

That's true, I hadn't remembered that.  Not _very_ confusing,
but the last thing I'd want is to bully everyone into changing
their familiar name for something, and the result just as poor.
No need to decide today anyway: let's see how others feel.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
