Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 389A16B002D
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 09:37:54 -0400 (EDT)
Date: Mon, 31 Oct 2011 08:37:49 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] cache align vm_stat
Message-ID: <20111031133749.GB17076@sgi.com>
References: <20111024161035.GA19820@sgi.com>
 <alpine.DEB.2.00.1110262131240.27107@router.home>
 <20111028155456.20f3d611.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111028155456.20f3d611.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>

On Fri, Oct 28, 2011 at 03:54:56PM -0700, Andrew Morton wrote:
> On Wed, 26 Oct 2011 21:31:46 -0500 (CDT)
> Christoph Lameter <cl@gentwo.org> wrote:
> 
> > On Mon, 24 Oct 2011, Dimitri Sivanich wrote:
> > 
> > > Avoid false sharing of the vm_stat array.
> 
> Did we have some nice machine-description and measurement results which
> can be included in the changelog?  Such things should always be
> included with a performace patch!
> 
Tests run on a 640 cpu UV system.

With 120 threads doing parallel writes, each to different tmpfs mounts:
No patch:		~300 MB/sec
With vm_stat alignment:	~430 MB/sec

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
