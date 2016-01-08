Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 19DE0828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 13:28:10 -0500 (EST)
Received: by mail-yk0-f173.google.com with SMTP id k129so348917544yke.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 10:28:10 -0800 (PST)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id c202si9294576ywa.56.2016.01.08.10.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 10:28:09 -0800 (PST)
Received: by mail-yk0-x22e.google.com with SMTP id a85so293751183ykb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 10:28:09 -0800 (PST)
Date: Fri, 8 Jan 2016 13:28:08 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/5] x86, memhp, numa: Online memory-less nodes at boot
 time.
Message-ID: <20160108182808.GZ1898@mtj.duckdns.org>
References: <1452140425-16577-1-git-send-email-tangchen@cn.fujitsu.com>
 <1452140425-16577-2-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452140425-16577-2-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: cl@linux.com, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Thu, Jan 07, 2016 at 12:20:21PM +0800, Tang Chen wrote:
> +static void __init init_memory_less_node(int nid)
>  {
> +	unsigned long zones_size[MAX_NR_ZONES] = {0};
> +	unsigned long zholes_size[MAX_NR_ZONES] = {0};

It doesn't cause any functional difference but it's a bit weird to use
{0} because it explicitly says to initialize the first element to 0
when the whole array needs to be cleared.  Wouldnt { } make more sense?

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e23a9e7..9c4d4d5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -736,6 +736,7 @@ static inline bool is_dev_zone(const struct zone *zone)
>  
>  extern struct mutex zonelists_mutex;
>  void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
> +void build_zonelists(pg_data_t *pgdat);

This isn't used in this patch.  Contamination?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
