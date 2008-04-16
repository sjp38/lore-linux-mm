Date: Wed, 16 Apr 2008 12:19:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] use vmalloc for mem_cgroup allocation.
In-Reply-To: <20080415105434.3044afb6.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0804161219190.14718@schroedinger.engr.sgi.com>
References: <20080415105434.3044afb6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, lizf@cn.fujitsu.com, menage@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Apr 2008, KAMEZAWA Hiroyuki wrote:

> On ia64, kmalloc() in mem_cgroup_create requires order-4 pages. But this is not
> necessary to be phisically contiguous. And we'll see page allocation failure.
> (Note: x86-32, which has small vmalloc area, has small mem_cgroup struct.)
> For here, vmalloc is better.

I need to get my virtualizable compound stuff in order. That would address 
these issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
