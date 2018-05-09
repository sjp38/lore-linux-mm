Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDE5E6B0344
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:49:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 35-v6so3291446pla.18
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:49:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9-v6si26433579plk.516.2018.05.09.00.48.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 00:48:59 -0700 (PDT)
Date: Wed, 9 May 2018 09:48:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [External]  Re: [PATCH 3/3] mm/page_alloc: Fix typo in debug
 info of calculate_node_totalpages
Message-ID: <20180509074857.GD32366@dhcp22.suse.cz>
References: <1525416729-108201-1-git-send-email-yehs1@lenovo.com>
 <1525416729-108201-4-git-send-email-yehs1@lenovo.com>
 <20180504131854.GQ4535@dhcp22.suse.cz>
 <HK2PR03MB16841DAC9D4C5D0569676F7692850@HK2PR03MB1684.apcprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <HK2PR03MB16841DAC9D4C5D0569676F7692850@HK2PR03MB1684.apcprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng HS1 Ye <yehs1@lenovo.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sat 05-05-18 02:10:35, Huaisheng HS1 Ye wrote:
[...]
> But this printk is a relatively meaningful reference within dmesg log.
> Especially for people who doesn't have much experience, or someone
> has a plan to modify boundary of zones within free_area_init_*.

Could you be more specific please? I am not saying that the printk is
pointless but it is DEBUG and as such it doesn't give us a very good
picture.

-- 
Michal Hocko
SUSE Labs
