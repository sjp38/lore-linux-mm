Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 8DED56B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 02:59:35 -0500 (EST)
Message-ID: <50F900A3.4060903@cn.fujitsu.com>
Date: Fri, 18 Jan 2013 15:58:27 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/2] memory-hotplug: introduce CONFIG_HAVE_BOOTMEM_INFO_NODE
 and revert register_page_bootmem_info_node() when platform not support
References: <1358324059-9608-1-git-send-email-linfeng@cn.fujitsu.com> <1358324059-9608-2-git-send-email-linfeng@cn.fujitsu.com> <20130116141436.GE343@dhcp22.suse.cz> <50F7D456.9000904@cn.fujitsu.com> <20130117130509.GE20538@dhcp22.suse.cz>
In-Reply-To: <20130117130509.GE20538@dhcp22.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, jbeulich@suse.com, dhowells@redhat.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, paul.gortmaker@windriver.com, laijs@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, jiang.liu@huawei.com, tony.luck@intel.com, fenghua.yu@intel.com, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, michael@ellerman.id.au, gerald.schaefer@de.ibm.com, gregkh@linuxfoundation.org, x86@kernel.org, linux390@de.ibm.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com

Hi Michal,

On 01/17/2013 09:05 PM, Michal Hocko wrote:
> On Thu 17-01-13 18:37:10, Lin Feng wrote:
> [...]
>>> > > I am still not sure I understand the relation to MEMORY_HOTREMOVE.
>>> > > Is register_page_bootmem_info_node required/helpful even if
>>> > > !CONFIG_MEMORY_HOTREMOVE?
>> > From old kenrel's view register_page_bootmem_info_node() is defined in 
>> > CONFIG_MEMORY_HOTPLUG_SPARSE, it registers some info for 
>> > memory hotplug/remove. If we don't use MEMORY_HOTPLUG feature, this
>> > function is empty, we don't need the info at all.
>> > So this info is not required/helpful if !CONFIG_MEMORY_HOTREMOVE.
> OK, then I suggest moving it under CONFIG_MEMORY_HOTREMOVE guards rather
> than CONFIG_MEMORY_HOTPLUG.
I can't agree more ;-) 
I also find that page_isolation.c selected by MEMORY_ISOLATION under MEMORY_HOTPLUG
is also such case, I fix it by the way.

thanks,
linfeng
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
