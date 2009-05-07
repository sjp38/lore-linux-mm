Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8B36B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 09:13:36 -0400 (EDT)
Date: Thu, 7 May 2009 14:13:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
In-Reply-To: <20090507113120.GH16078@random.random>
Message-ID: <Pine.LNX.4.64.0905071339220.12379@blonde.anvils>
References: <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com>
 <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com>
 <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
 <20090506133434.GX16078@random.random> <4A019719.7030504@redhat.com>
 <Pine.LNX.4.64.0905061739540.5934@blonde.anvils> <20090506164945.GD15712@x200.localdomain>
 <20090507113120.GH16078@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Wright <chrisw@redhat.com>, Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Thu, 7 May 2009, Andrea Arcangeli wrote:
> 
> What this thing does is to create shared pages by merging equal pages...
> 
> While I don't care about the naming much myself, one problem I have is
> that I've been writing a KSM paper for linuxsymposium and I'd like to
> use a nomenclature that is in sync with how this stuff should be
> called on lkml, to avoid confusion.

Sorry for sparking this namechange at such a late date,
inflicting such nuisance upon you.

> 
> So should I change the simpler word KSM with "Memory Merging feature"
> all over the paper?

No: "KSM" stands for "Kernel Samepage Merging", doesn't it?
Or maybe someone can devise a better term for the "S" of it.

I think we're all too familiar with "KSM" to want to outlaw that,
just don't dwell too much on the "Kernel Shared Memory" expansion.

> 
> In addition I consistently use the term "shared KSM pages" often,
> should I rename all those instances to "merged pages"? I used the word
> 'merging' only when describing the operation KSM does when it creates
> shared pages, but never to name the generated pages themself.

No, you and your audience and your readers will find it clearest
if you remark on the change in naming upfront, then get on with
describing it all in the way that comes most naturally to you.

But do sprinkle in a few "merged pages", I suggest: perhaps by
the time you deliver it, they'll be coming more naturally to you.

(Actually, "shared KSM pages" makes more sense if that "S" is not
for Shared.  I keep wondering what the two "k"s in kksmd stand for.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
