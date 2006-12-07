Date: Thu, 7 Dec 2006 19:50:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2 [1/5] generic vmemmap on
 sparsemem
Message-Id: <20061207195023.11cb3b52.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061207101156.GB9059@osiris.ibm.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
	<20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com>
	<20061206181317.GA10042@osiris.ibm.com>
	<Pine.LNX.4.64.0612061014210.26523@schroedinger.engr.sgi.com>
	<20061207092042.33533708.kamezawa.hiroyu@jp.fujitsu.com>
	<20061207101156.GB9059@osiris.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Dec 2006 11:11:56 +0100
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> > > vmap_end is only page aligned if sizeof(struct page) and PAGES_PER_SECTION
> > > play nicely together. Which may not be the case on 64 bit platforms where
> > > sizeof(struct page) is not a power of two.
> > >
> > Now, (for example ia64) sizeof(struct page)=56 and PAGES_PER_SECTION=65536,
> > Then, sizeof(struct page) * PAGES_PER_SECTION is page-aligned.(16kbytes pages.)
> 
> sizeof(struct page) depends also on at least two CONFIG options. I don't
> think it's a good idea to assume that everything is page aligned, just
> because it works right now and only with certain kernel configurations...
> At least the kernel build should fail if your assumptions are not true
> anymore.
> 
I'll add #error and check it. thanks.

-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
