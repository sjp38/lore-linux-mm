Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 390D86B0078
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 01:53:48 -0500 (EST)
Date: Tue, 26 Jan 2010 08:53:03 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126065303.GJ8483@redhat.com>
References: <patchbomb.1264054824@v2.random>
 <alpine.DEB.2.00.1001220845000.2704@router.home>
 <20100122151947.GA3690@random.random>
 <alpine.DEB.2.00.1001221008360.4176@router.home>
 <20100123175847.GC6494@random.random>
 <alpine.DEB.2.00.1001251529070.5379@router.home>
 <4B5E3CC0.2060006@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B5E3CC0.2060006@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 07:52:16PM -0500, Rik van Riel wrote:
> On 01/25/2010 04:50 PM, Christoph Lameter wrote:
> 
> >So its not possible to use these "huge" pages in a useful way inside of
> >the kernel. They are volatile and temporary.
> 
> >In short they cannot be treated as 2M entities unless we add some logic to
> >prevent splitting.
> >
> >Frankly this seems to be adding splitting that cannot be used if one
> >really wants to use large pages for something.
> 
> What exactly do you need the stable huge pages for?
> 
> Do you have anything specific in mind that we should take
> into account?
> 
> Want to send in an incremental patch that can temporarily block
> the pageout code from splitting up a huge page, so your direct
> users of huge pages can rely on them sticking around until the
> transaction is done?
> 
Shouldn't mlock() do the trick?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
