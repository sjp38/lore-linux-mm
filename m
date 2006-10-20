Date: Thu, 19 Oct 2006 19:26:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
In-Reply-To: <20061020110618.6423d0e4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0610191925180.12581@schroedinger.engr.sgi.com>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610190932310.8072@schroedinger.engr.sgi.com>
 <20061020101857.b795f143.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610191838420.11820@schroedinger.engr.sgi.com>
 <20061020110618.6423d0e4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Oct 2006, KAMEZAWA Hiroyuki wrote:

> By the way, we have to make sizeof(struct page) as (1 << x) aligned size to use
> large-sized page. (IIRC, my gcc-3.4.3 says it is 56bytes....)

Having it 1 << x would be useful to simplify the pfn_valid check but 
you can also check the start and the end of the page struct to allow the 
page struct cross a page boundary. See the ia64 virtual memmap 
implementation of pfn_valid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
