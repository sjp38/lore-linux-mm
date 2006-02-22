Date: Tue, 21 Feb 2006 19:41:20 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] remove zone_mem_map
In-Reply-To: <43FBD995.20601@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0602211939210.26289@schroedinger.engr.sgi.com>
References: <43FBAEBA.2020300@jp.fujitsu.com>
 <Pine.LNX.4.64.0602211900450.23557@schroedinger.engr.sgi.com>
 <43FBD995.20601@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Feb 2006, KAMEZAWA Hiroyuki wrote:

> BTW, ia64 looks very special. Does it make sensible performance gain ?

Well yes, we actually have virtual mappings in kernel address space. 
F.e. The hotplug remove issues could be fixed there by remapping pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
