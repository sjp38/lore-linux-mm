Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 3FA5B6B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 01:42:16 -0400 (EDT)
Message-ID: <51BAADE8.2040501@cn.fujitsu.com>
Date: Fri, 14 Jun 2013 13:45:12 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part3 PATCH v2 2/4] mem-hotplug: Skip LOCAL_NODE_DATA pages
 in memory offline procedure.
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com> <1371128636-9027-3-git-send-email-tangchen@cn.fujitsu.com> <51B9FE8E.9000109@intel.com>
In-Reply-To: <51B9FE8E.9000109@intel.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Dave,

On 06/14/2013 01:17 AM, Dave Hansen wrote:
> On 06/13/2013 06:03 AM, Tang Chen wrote:
>> +static inline bool is_local_node_data(struct page *page)
>> +{
>> +	return (unsigned long)page->lru.next == LOCAL_NODE_DATA;
>> +}
>
> page->lru is already in a union.  Could you please just add a new entry
> to the union with a nice associated comment instead of reusing it this way?
>

You mean add a new entry to the union in page structure ?

Hum, seems a good idea. :)

And as you know, NODE_INFO, SECTION_INFO, ... , they all reuse page->lru.
So I need to modify the associated code too. This is easy to do, and I can
do it in the next version soon.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
