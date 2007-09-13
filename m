Date: Thu, 13 Sep 2007 10:27:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] overwride page->mapping [0/3] intro
Message-Id: <20070913102705.91580d88.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0709121804040.4912@schroedinger.engr.sgi.com>
References: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
	<46E7A666.7080409@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0709121207400.1934@schroedinger.engr.sgi.com>
	<46E83A19.2090604@google.com>
	<20070913093203.841b76a7.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0709121804040.4912@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007 18:05:04 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 13 Sep 2007, KAMEZAWA Hiroyuki wrote:
> 
> > Some machine may have very sparse address configuration from unknown(insane) reason.
> 
> The HW engineers always find uses for those "unused" address bits.... And 
> frankly we have done the same using a special address range for the VMEMMAP patchset.
> 
I know (current) ia64 just uses 50bits.

Anyway, I think something like this
==
struct page_container * pfn_to_pagecontainer(unsigned long pfn);
#define page_to_container(page)	pfn_to_pagecontainer(page_to_pfn(page))
==
is not very easy.

thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
