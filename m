Date: Mon, 11 Dec 2006 10:09:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2
Message-Id: <20061211100931.e3118330.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061210151931.GB28442@osiris.ibm.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
	<457C0D86.70603@shadowen.org>
	<20061210151931.GB28442@osiris.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: apw@shadowen.org, linux-mm@kvack.org, clameter@engr.sgi.com, schwidefsky@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Sun, 10 Dec 2006 16:19:31 +0100
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> > Would we expect to see this replace the existing ia64 implementation in
> > the long term?  I'd hate to see us having competing implementations
> > here.  Also Heiko would this framework with your s390 requirements for
> > vmem_map, I know that you have a particularly challenging physical
> > layout?  It would be great to see just one of these in the kernel.
> 
> Hmm.. this implementation still requires sparsemem. Maybe it would be
> possible to implement a generic vmem_map infrastructure that works with
> and without sparsemem?

Maybe we need
(1) stop making use of PAGE_SIZE alignment of sprasemem's mem_map
(2) implement pfn_valid().
(3) add generic style call for creating mem_map from the list of pfn range
    and vmem_map alignment concept.

other ?
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
