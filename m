Date: Sat, 25 Feb 2006 10:31:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [RFC] for_each_page_in_zone [1/1]
Message-Id: <20060225103113.644191cb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060225102443.22b5727e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20060224171518.29bae84b.kamezawa.hiroyu@jp.fujitsu.com>
	<1140795826.8697.86.camel@localhost.localdomain>
	<20060225102443.22b5727e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: haveblue@us.ibm.com, linux-mm@kvack.org, pavel@suse.cz, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sat, 25 Feb 2006 10:24:43 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:


> Oh......maybe this code is ok?
> --
> do {
> 	pfn = next_valid_pfn(pfn, zone->zone_start_pfn + zone->zone->spanned_pages);
> }while(page_zone(pfn_to_page(pfn)) !-= zone);
> --
> I think powerpc uses SPARSEMEM when NUMA, so pfn is efficientlly skipped.
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Ignore above (><

This code doesn't change current inefficiency...so more optimization (with some assumption or
with some helper information) can be done in future..

--Kame                                    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
