Message-ID: <45D48075.8000709@mbligh.org>
Date: Thu, 15 Feb 2007 07:47:01 -0800
From: "Martin J. Bligh" <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] Add PageMlocked() page state bit and lru infrastructure
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com> <20070215012459.5343.72021.sendpatchset@schroedinger.engr.sgi.com> <20070215020916.GS10108@waste.org> <Pine.LNX.4.64.0702141829410.5747@schroedinger.engr.sgi.com> <20070215145138.GT10108@waste.org> <Pine.LNX.4.64.0702150722580.10403@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702150722580.10403@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 15 Feb 2007, Matt Mackall wrote:
> 
>> Fine. But -this- comment is still incorrect. If someone were to ask
>> "what does this bit mean?" they would go the list of bit definitions
>> and leave with the -wrong- answer. The page is not necessarily
>> mlocked, it's just on the lazy mlock list.
> 
> Well maybe we need to redo all the comments there in a consistent way. The 
> other comments are equally sparse. Takes me a long time when try to 
> figure out the role of a particular bit.

Absolutely agree, especially as they seem to be getting more and more
complicated and the rules get more and more obscure. (and we all get
old ;-))

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
