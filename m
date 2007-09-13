Date: Thu, 13 Sep 2007 09:32:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] overwride page->mapping [0/3] intro
Message-Id: <20070913093203.841b76a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <46E83A19.2090604@google.com>
References: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
	<46E7A666.7080409@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0709121207400.1934@schroedinger.engr.sgi.com>
	<46E83A19.2090604@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007 12:12:25 -0700
Martin Bligh <mbligh@google.com> wrote:

> Christoph Lameter wrote:
> > On Wed, 12 Sep 2007, Balbir Singh wrote:
> > 
> >> We discussed the struct page size issue at VM summit. If I remember
> >> correctly, Linus suggested that we consider using pfn's instead of
> >> pointers for pointer members in struct page.
> > 
> > How would that save any memory? On a system with 16TB memory and 4k page 
> > size you have at least 4 billion pfns which is the max that an unsigned 
> > int can handle. If the virtual address space is sparse or larger (like on 
> > IA64) then you need to use an int with more than 32 bit anyways.
> 
> Because nobody (sane) has 16TB of memory? ;-)
> 
I think it's not problem of size of memory. 
It's problem of size of address space, 64 bit.

Some machine may have very sparse address configuration from unknown(insane) reason.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
