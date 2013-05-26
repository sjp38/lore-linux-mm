From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [patch v2 3/6] mm/memory_hotplug: Disable memory hotremove for
 32bit
Date: Sun, 26 May 2013 17:06:17 +0800
Message-ID: <45172.4534541883$1369559196@news.gmane.org>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1369547921-24264-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130526090054.GE10651@dhcp22.suse.cz>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UgWuK-000624-Mr
	for glkm-linux-mm-2@m.gmane.org; Sun, 26 May 2013 11:06:29 +0200
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 967B16B0089
	for <linux-mm@kvack.org>; Sun, 26 May 2013 05:06:26 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 26 May 2013 18:53:11 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 96C952BB0050
	for <linux-mm@kvack.org>; Sun, 26 May 2013 19:06:20 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4Q8q7QO19923010
	for <linux-mm@kvack.org>; Sun, 26 May 2013 18:52:07 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4Q96Jcd004082
	for <linux-mm@kvack.org>; Sun, 26 May 2013 19:06:19 +1000
Content-Disposition: inline
In-Reply-To: <20130526090054.GE10651@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

On Sun, May 26, 2013 at 11:00:54AM +0200, Michal Hocko wrote:
>On Sun 26-05-13 13:58:38, Wanpeng Li wrote:
>> As KOSAKI Motohiro mentioned, memory hotplug don't support 32bit since 
>> it was born, 
>
>Why? any reference? This reasoning is really weak.
>

http://marc.info/?l=linux-mm&m=136953099010171&w=2

>> this patch disable memory hotremove when 32bit at compile 
>> time.
>> 
>> Suggested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/Kconfig | 1 +
>>  1 file changed, 1 insertion(+)
>> 
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index e742d06..ada9569 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -184,6 +184,7 @@ config MEMORY_HOTREMOVE
>>  	bool "Allow for memory hot remove"
>>  	select MEMORY_ISOLATION
>>  	select HAVE_BOOTMEM_INFO_NODE if X86_64
>> +	depends on 64BIT
>>  	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>>  	depends on MIGRATION
>>  
>> -- 
>> 1.8.1.2
>> 
>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
