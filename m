Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 814B06B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 05:28:06 -0500 (EST)
Message-ID: <50F52EF8.7050605@cn.fujitsu.com>
Date: Tue, 15 Jan 2013 18:27:04 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: revert register_page_bootmem_info_node()
 to empty when platform related code is not implemented
References: <1358160835-30617-1-git-send-email-linfeng@cn.fujitsu.com> <20130114184308.GD5126@dhcp22.suse.cz>
In-Reply-To: <20130114184308.GD5126@dhcp22.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, wency@cn.fujitsu.com, jiang.liu@huawei.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com

Hi Michal,

I have updated to V2 version according to what you said, would you please take a look 
if it conforms to what you think? 

thanks,
linfeng

On 01/15/2013 02:43 AM, Michal Hocko wrote:
> This is just ugly. Could you please add something like HAVE_BOOTMEM_INFO_NODE
> or something with a bettern name and let CONFIG_MEMORY_HOTPLUG select it
> for supported architectures and configurations (e.g.
> CONFIG_SPARSEMEM_VMEMMAP doesn't need a special arch support, right?).
> These Todo things are just too messy.
> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
