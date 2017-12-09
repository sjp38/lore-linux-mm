Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE406B0277
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 21:42:32 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id m9so10262102pff.0
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 18:42:32 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id j16si5916008pli.331.2017.12.08.18.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 18:42:30 -0800 (PST)
Date: Sat, 9 Dec 2017 10:42:20 +0800
From: Fengguang Wu <lkp@intel.com>
Subject: Re: [PATCH v2] mm: Add unmap_mapping_pages
Message-ID: <20171209024220.bwvzswwckhvbr6qy@wfg-t540p.sh.intel.com>
References: <20171205154453.GD28760@bombadil.infradead.org>
 <201712080802.CQcwOznF%fengguang.wu@intel.com>
 <20171209013624.GA9717@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20171209013624.GA9717@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: kbuild-all@01.org, linux-mm@kvack.org, "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org, Ye Xiaolong <xiaolong.ye@intel.com>

CC Xiaolong.

On Fri, Dec 08, 2017 at 05:36:24PM -0800, Matthew Wilcox wrote:
>On Fri, Dec 08, 2017 at 10:38:55AM +0800, kbuild test robot wrote:
>> Hi Matthew,
>>
>> I love your patch! Yet something to improve:
>
>You missed v3, kbuild robot?

Yeah indeed. Something went wrong and the patch service log has not
been updated for 3 days.. Let's check it.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
