Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id F3DC66B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 06:30:40 -0400 (EDT)
Message-ID: <50166379.4090305@cn.fujitsu.com>
Date: Mon, 30 Jul 2012 18:35:37 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v5 12/19] memory-hotplug: introduce new function arch_remove_memory()
References: <50126B83.3050201@cn.fujitsu.com> <50126E2F.8010301@cn.fujitsu.com> <20120730102305.GB3631@osiris.boeblingen.de.ibm.com>
In-Reply-To: <20120730102305.GB3631@osiris.boeblingen.de.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

At 07/30/2012 06:23 PM, Heiko Carstens Wrote:
> On Fri, Jul 27, 2012 at 06:32:15PM +0800, Wen Congyang wrote:
>> We don't call __add_pages() directly in the function add_memory()
>> because some other architecture related things need to be done
>> before or after calling __add_pages(). So we should introduce
>> a new function arch_remove_memory() to revert the things
>> done in arch_add_memory().
>>
>> Note: the function for s390 is not implemented(I don't know how to
>> implement it for s390).
> 
> There is no hardware or firmware interface which could trigger a
> hot memory remove on s390. So there is nothing that needs to be
> implemented.

Thanks for providing this information.

According to this, arch_remove_memory() for s390 can just return -EBUSY.

Thanks
Wen Congyang

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
