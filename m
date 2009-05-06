Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 714476B00AA
	for <linux-mm@kvack.org>; Wed,  6 May 2009 11:36:22 -0400 (EDT)
Date: Wed, 6 May 2009 08:36:50 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
Message-ID: <20090506153650.GA15712@x200.localdomain>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com> <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils> <20090506133434.GX16078@random.random> <Pine.LNX.4.64.0905061453320.21067@blonde.anvils> <20090506144558.GZ16078@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090506144558.GZ16078@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>, Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

* Andrea Arcangeli (aarcange@redhat.com) wrote:
> On Wed, May 06, 2009 at 03:25:25PM +0100, Hugh Dickins wrote:
> > silently ignore may fit better with whether module has been loaded yet
> > (we can keep a list of what's registered, for when module is loaded).
> 
> NOTE: it will not fail if the module isn't loaded yet. It must
> succeed! Otherwise it would also need to fail after it succeeded if we
> unload the module later...

I actually see little value in it even being modular.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
