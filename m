Message-ID: <43FBDFF9.4080002@jp.fujitsu.com>
Date: Wed, 22 Feb 2006 12:52:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] remove zone_mem_map
References: <43FBAEBA.2020300@jp.fujitsu.com> <Pine.LNX.4.64.0602211900450.23557@schroedinger.engr.sgi.com> <43FBD995.20601@jp.fujitsu.com> <Pine.LNX.4.64.0602211939210.26289@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0602211939210.26289@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 22 Feb 2006, KAMEZAWA Hiroyuki wrote:
> 
>> BTW, ia64 looks very special. Does it make sensible performance gain ?
> 
> Well yes, we actually have virtual mappings in kernel address space. 
> F.e. The hotplug remove issues could be fixed there by remapping pages.
> 
Ah, if we place node_data[i](array of pointer to pgdat) in region 7,
there is no trouble ?
(maybe zone_table[] should be also..)

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
