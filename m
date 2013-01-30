Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 9CD636B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 17:48:16 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xa12so1237178pbc.36
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 14:48:15 -0800 (PST)
Date: Wed, 30 Jan 2013 14:48:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH Bug fix] acpi, movablemem_map: node0 should always be
 unhotpluggable when using SRAT.
In-Reply-To: <5108F6A1.6060400@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1301301445270.27852@chino.kir.corp.google.com>
References: <1359532470-28874-1-git-send-email-tangchen@cn.fujitsu.com> <alpine.DEB.2.00.1301300049100.19679@chino.kir.corp.google.com> <5108E245.9060501@cn.fujitsu.com> <alpine.DEB.2.00.1301300139070.25371@chino.kir.corp.google.com>
 <5108F6A1.6060400@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 30 Jan 2013, Tang Chen wrote:

> > Exactly, there is a node 0 but it includes no online memory (and that
> > should be the case as if it was solely hotpluggable memory) at the time of
> > boot.  The sysfs interfaces only get added if the memory is onlined later.
> 
> OK, you mean you have only node1 at first and no node0 interface, right?
> If so, then this patch is wrong. :)
> 

Not usually unless I modify my SRAT or I start pulling DIMMs, but yes, 
I've booted the kernel many times in the past with no node 0 online.  As 
far as I know, there's no special casing that is needed for node 0 to 
assume it's online and I've tried to fix up places where that assumption 
has been made.  I'm sure that node_online_map must include at least one 
online node, obviously, but there should be no requirement that it be node 
0.

> But you mean physical address 0x0 is on your node1, right? Otherwise, how
> could
> the kernel be loaded ?
> 

Yes, the online pxms all point to nodes that do not have the node id of 0.

Is it possible to try earlyprintk and get a serial console connected or 
reproduce it locally to find out where the problem is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
