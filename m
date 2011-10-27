Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 621376B002D
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 22:31:50 -0400 (EDT)
Date: Wed, 26 Oct 2011 21:31:46 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] cache align vm_stat
In-Reply-To: <20111024161035.GA19820@sgi.com>
Message-ID: <alpine.DEB.2.00.1110262131240.27107@router.home>
References: <20111024161035.GA19820@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>

On Mon, 24 Oct 2011, Dimitri Sivanich wrote:

> Avoid false sharing of the vm_stat array.

Acked-by: Christoph Lameter <cl@gentwo.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
