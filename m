Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB7AC6jm191404
	for <linux-mm@kvack.org>; Thu, 7 Dec 2006 10:12:06 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB7AC6dR2244670
	for <linux-mm@kvack.org>; Thu, 7 Dec 2006 10:12:06 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB7AC5O1021003
	for <linux-mm@kvack.org>; Thu, 7 Dec 2006 10:12:06 GMT
Date: Thu, 7 Dec 2006 11:11:56 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2 [1/5] generic vmemmap on sparsemem
Message-ID: <20061207101156.GB9059@osiris.ibm.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com> <20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com> <20061206181317.GA10042@osiris.ibm.com> <Pine.LNX.4.64.0612061014210.26523@schroedinger.engr.sgi.com> <20061207092042.33533708.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061207092042.33533708.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

> > vmap_end is only page aligned if sizeof(struct page) and PAGES_PER_SECTION
> > play nicely together. Which may not be the case on 64 bit platforms where
> > sizeof(struct page) is not a power of two.
> >
> Now, (for example ia64) sizeof(struct page)=56 and PAGES_PER_SECTION=65536,
> Then, sizeof(struct page) * PAGES_PER_SECTION is page-aligned.(16kbytes pages.)

sizeof(struct page) depends also on at least two CONFIG options. I don't
think it's a good idea to assume that everything is page aligned, just
because it works right now and only with certain kernel configurations...
At least the kernel build should fail if your assumptions are not true
anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
