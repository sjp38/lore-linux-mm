Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB4DU9H4150498
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:30:09 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB4DU9Re2060354
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:30:09 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB4DU8mX023536
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:30:09 GMT
Date: Mon, 4 Dec 2006 14:30:08 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch/rfc 0/2] vmemmap for s390
Message-ID: <20061204133008.GA9209@osiris.boeblingen.de.ibm.com>
References: <20061201140542.GA8788@osiris.boeblingen.de.ibm.com> <20061204104714.bc800a03.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061204104714.bc800a03.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, schwidefsky@de.ibm.com, cotte@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Dec 04, 2006 at 10:47:14AM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 1 Dec 2006 15:05:42 +0100
> Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> 
> > This is the s390 implementation (both 31 and 64 bit) of a virtual memmap.
> > ia64 was used as a blueprint of course. I hope I incorporated everything
> > I read lately on linux-mm wrt. vmemmap.
> > So I post this as an RFC, since I most probably have forgotten something,
> > or did something wrong. Comments highly appreciated.
> >
> > This patchset is against linux-2.6.19-rc6-mm2.
> >
> > Patch 1 is sort of unrelated to the vmemmap patch but still needed, so
> > that the patch applies.
> > Patch 2 is the vmemmap implementation.
> >
> 
> - Could you divide Patch 2 into a few pieces ?
>   * setup, vmemmap pagetable creation, shared memory codes , etc...

Yes, will do.

> - Do you need vmemmap for 32 bits ? (just a question)

Yes, because of two reasons:

- this way we can use the same code for both 31 and 64 bit, which simplifies
  maintenance.

- if we convert to Mel Gorman's 'add_active_range' interface then we still
  need a way to add/initialize struct pages. Mel's new interface limits the
  size of the created mem_map to the largest valid pfn passed via
  'add_active_range'. Hence there is no way to add additional struct pages
  to the end of the initial mem_map, even if 'mem=...' was given via the
  kernel command line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
