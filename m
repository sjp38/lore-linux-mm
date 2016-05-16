Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 81A876B025E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 05:59:16 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e63so349847663iod.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:59:16 -0700 (PDT)
Received: from szxga01-in.huawei.com ([58.251.152.64])
        by mx.google.com with ESMTPS id h32si11269492otc.157.2016.05.16.02.59.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 02:59:16 -0700 (PDT)
Message-ID: <573999BB.5090005@huawei.com>
Date: Mon, 16 May 2016 17:58:19 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: why the count nr_file_pages is not equal to nr_inactive_file
 + nr_active_file ?
References: <573550D8.9030507@huawei.com> <20160516093146.GA23251@dhcp22.suse.cz>
In-Reply-To: <20160516093146.GA23251@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Aaron Lu <aaron.lu@intel.com>

On 2016/5/16 17:31, Michal Hocko wrote:

> On Fri 13-05-16 11:58:16, Xishi Qiu wrote:
>> I find the count nr_file_pages is not equal to nr_inactive_file + nr_active_file.
>> There are 8 cpus, 2 zones in my system.
> 
> Because they count shmem pages as well and those are living on the anon
> lru list (see shmem_add_to_page_cache).

Hi Michal,

But the shmem seems very small.

nr_inactive_file 432444
nr_active_file 20659
nr_unevictable 2363
nr_shmem 128

nr_file_pages 462723

There is still 7129 pages difference.

root@hi3650:/ # cat /proc/vmstat 
nr_free_pages 54192
nr_inactive_anon 39830
nr_active_anon 28794
nr_inactive_file 432444
nr_active_file 20659
nr_unevictable 2363
nr_mlock 0
nr_anon_pages 65249
nr_mapped 19742
nr_file_pages 462723
nr_dirty 20
nr_writeback 0
nr_slab_reclaimable 259333
nr_slab_unreclaimable 33463
nr_page_table_pages 3456
nr_kernel_stack 892
nr_unstable 0
nr_bounce 11
nr_vmscan_write 292032
nr_vmscan_immediate_reclaim 47204474
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 128
nr_dirtied 69574
nr_written 356299
nr_anon_transparent_hugepages 0
nr_free_cma 7519
nr_swapcache 41972
nr_dirty_threshold 6982
nr_dirty_background_threshold 99297

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
