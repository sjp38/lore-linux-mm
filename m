Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 176106B0092
	for <linux-mm@kvack.org>; Wed,  6 May 2009 09:50:45 -0400 (EDT)
Date: Wed, 6 May 2009 14:28:33 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses registrations.
In-Reply-To: <20090506131735.GW16078@random.random>
Message-ID: <Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com> <4A00DD4F.8010101@redhat.com>
 <4A015C69.7010600@redhat.com> <4A0181EA.3070600@redhat.com>
 <20090506131735.GW16078@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Andrea Arcangeli wrote:
> 
> For example for the swapping of KSM pages we've been thinking of using
> external rmap hooks to avoid the VM to know anything specific to KSM
> pages but to still allow their unmapping and swap.

There may prove to be various reasons why it wouldn't work out in practice;
but when thinking of swapping them, it is worth considering if those KSM
pages can just be assigned to a tmpfs file, then leave the swapping to that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
