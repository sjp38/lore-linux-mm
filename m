Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 637AF6B038B
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 10:14:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p189so6715823pfp.5
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 07:14:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s5si5427182pgj.372.2017.03.16.07.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 07:14:28 -0700 (PDT)
Date: Thu, 16 Mar 2017 22:14:38 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170316141437.GA16038@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
 <20170316073403.GE1661@aaronlu.sh.intel.com>
 <20170316135122.GF13054@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316135122.GF13054@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Thu, Mar 16, 2017 at 09:51:22PM +0800, Aaron Lu wrote:
> Considering that we are mostly improving for memory intensive apps, the
> default setting should probably be: max_active = node_number with each
> worker freeing 2G memory.

In case people want to give this setting a try, here is what to do.

On 2-nodes EP:
# echo 2 > /sys/devices/virtual/workqueue/batch_free_wq/max_active
# echo 1030 > /sys/kernel/debug/parallel_free/max_gather_batch_count

On 4-nodes EX:
# echo 4 > /sys/devices/virtual/workqueue/batch_free_wq/max_active
# echo 1030 > /sys/kernel/debug/parallel_free/max_gather_batch_count

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
