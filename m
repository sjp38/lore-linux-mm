Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 77A326B009B
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 12:32:17 -0400 (EDT)
Date: Thu, 18 Mar 2010 11:31:39 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 01/11] mm,migration: Take a reference to the anon_vma
 before migrating
In-Reply-To: <20100318111231.GJ12388@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003181131310.22889@router.home>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-2-git-send-email-mel@csn.ul.ie> <20100317103434.4C8B.A69D9226@jp.fujitsu.com> <20100317114537.GF12388@csn.ul.ie> <alpine.DEB.2.00.1003171138070.27268@router.home>
 <20100318111231.GJ12388@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Mar 2010, Mel Gorman wrote:

> Then even if we move to a full ref-count, it might still be a good idea
> to preserve the SLAB_DESTROY_BY_RCU.

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
