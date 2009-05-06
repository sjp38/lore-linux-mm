Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AC56E6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 12:42:22 -0400 (EDT)
Date: Wed, 6 May 2009 17:41:37 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
In-Reply-To: <4A019719.7030504@redhat.com>
Message-ID: <Pine.LNX.4.64.0905061739540.5934@blonde.anvils>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com>
 <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com>
 <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
 <20090506133434.GX16078@random.random> <4A019719.7030504@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Izik Eidus wrote:
> Andrea Arcangeli wrote:
> > On Wed, May 06, 2009 at 12:16:52PM +0100, Hugh Dickins wrote:
> >   
> >
> > > p.s.  I wish you'd chosen different name than KSM - the kernel
> > > has supported shared memory for many years - and notice ksm.c itself
> > > says "Memory merging driver".  "Merge" would indeed have been a less
> > > ambiguous term than "Share", but I think too late to change that now
> > > - except possibly in the MADV_ flag names?
> > >     
> >
> > I don't actually care about names, so I leave this to other to discuss.
> >   
> Well, There is no real problem changing the name, any suggestions?

mm/merge.c or mm/mmerge.c: the module formerly known as KSM ?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
