Date: Wed, 12 Sep 2007 12:10:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] overwride page->mapping [0/3] intro
In-Reply-To: <46E7A666.7080409@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0709121207400.1934@schroedinger.engr.sgi.com>
References: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
 <46E7A666.7080409@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "Martin J. Bligh" <mbligh@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Balbir Singh wrote:

> We discussed the struct page size issue at VM summit. If I remember
> correctly, Linus suggested that we consider using pfn's instead of
> pointers for pointer members in struct page.

How would that save any memory? On a system with 16TB memory and 4k page 
size you have at least 4 billion pfns which is the max that an unsigned 
int can handle. If the virtual address space is sparse or larger (like on 
IA64) then you need to use an int with more than 32 bit anyways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
