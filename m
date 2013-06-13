Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id F35806B0038
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 13:17:09 -0400 (EDT)
Message-ID: <51B9FE8E.9000109@intel.com>
Date: Thu, 13 Jun 2013 10:17:02 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [Part3 PATCH v2 2/4] mem-hotplug: Skip LOCAL_NODE_DATA pages
 in memory offline procedure.
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com> <1371128636-9027-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128636-9027-3-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/13/2013 06:03 AM, Tang Chen wrote:
> +static inline bool is_local_node_data(struct page *page)
> +{
> +	return (unsigned long)page->lru.next == LOCAL_NODE_DATA;
> +}

page->lru is already in a union.  Could you please just add a new entry
to the union with a nice associated comment instead of reusing it this way?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
