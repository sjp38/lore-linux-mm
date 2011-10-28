Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B047F6B002D
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 18:54:58 -0400 (EDT)
Date: Fri, 28 Oct 2011 15:54:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] cache align vm_stat
Message-Id: <20111028155456.20f3d611.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1110262131240.27107@router.home>
References: <20111024161035.GA19820@sgi.com>
	<alpine.DEB.2.00.1110262131240.27107@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>

On Wed, 26 Oct 2011 21:31:46 -0500 (CDT)
Christoph Lameter <cl@gentwo.org> wrote:

> On Mon, 24 Oct 2011, Dimitri Sivanich wrote:
> 
> > Avoid false sharing of the vm_stat array.

Did we have some nice machine-description and measurement results which
can be included in the changelog?  Such things should always be
included with a performace patch!

> Acked-by: Christoph Lameter <cl@gentwo.org>

Do christoph@lameter.com, cl@linux-foundation.org and cl@linux.com still work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
