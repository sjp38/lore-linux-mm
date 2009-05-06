Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0956B005D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 13:11:23 -0400 (EDT)
Date: Wed, 6 May 2009 18:11:13 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses registrations.
In-Reply-To: <4A01987A.6070002@redhat.com>
Message-ID: <Pine.LNX.4.64.0905061810320.8344@blonde.anvils>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com> <4A00DD4F.8010101@redhat.com>
 <4A015C69.7010600@redhat.com> <4A0181EA.3070600@redhat.com>
 <20090506131735.GW16078@random.random> <Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
 <4A01987A.6070002@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Izik Eidus wrote:
> Hugh Dickins wrote:
> >
> > There may prove to be various reasons why it wouldn't work out in practice;
> > but when thinking of swapping them, it is worth considering if those KSM
> > pages can just be assigned to a tmpfs file, then leave the swapping to that.
> 
> The problem here (as i see it) is reverse mapping for this vmas that point
> into the shared page.
> Right now linux use the ->index to find this pages and then unpresent them...
> But even if we move into allocating them inside tmpfs, who will know how to
> unpresent the virtual addresses when we want to swap the page?

Yes, you're right, tmpfs wouldn't be helping you at all with that problem,
so doubtful whether it has any help to offer here.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
