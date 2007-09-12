Date: Wed, 12 Sep 2007 12:17:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] overwride page->mapping [0/3] intro
In-Reply-To: <46E83A19.2090604@google.com>
Message-ID: <Pine.LNX.4.64.0709121214240.1934@schroedinger.engr.sgi.com>
References: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
 <46E7A666.7080409@linux.vnet.ibm.com> <Pine.LNX.4.64.0709121207400.1934@schroedinger.engr.sgi.com>
 <46E83A19.2090604@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Martin Bligh wrote:

> Because nobody (sane) has 16TB of memory? ;-)

Both our IA64 and the upcoming x86_64 line have the capability to address 
more than 16TB of memory.

include/asm-ia64/sparsemem.h has

#define MAX_PHYSMEM_BITS        (50)

(which is too low. We may have 4 Petabytes configurations sson so we want 
this to be 54 or so)

and we are working on increasing x86_64 ....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
