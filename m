Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id EC7306B0008
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:50:29 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id un1so838232pbc.26
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 00:50:29 -0800 (PST)
Date: Wed, 30 Jan 2013 00:50:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH Bug fix] acpi, movablemem_map: node0 should always be
 unhotpluggable when using SRAT.
In-Reply-To: <1359532470-28874-1-git-send-email-tangchen@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1301300049100.19679@chino.kir.corp.google.com>
References: <1359532470-28874-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 30 Jan 2013, Tang Chen wrote:

> When using movablemem_map=acpi, always set node0 as unhotpluggable, otherwise
> if all the memory is hotpluggable, the kernel will fail to boot.
> 
> When using movablemem_map=nn[KMG]@ss[KMG], we don't stop users specifying
> node0 as hotpluggable, and ignore all the info in SRAT, so that this option
> can be used as a workaround of firmware bugs.
> 

Could you elaborate on the failure you're seeing?

I've booted the kernel many times without memory on a node 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
