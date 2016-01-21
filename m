Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7396B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 16:26:53 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id a85so64260303ykb.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 13:26:53 -0800 (PST)
Received: from mail-yk0-x242.google.com (mail-yk0-x242.google.com. [2607:f8b0:4002:c07::242])
        by mx.google.com with ESMTPS id z65si1126090ywe.141.2016.01.21.13.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 13:26:52 -0800 (PST)
Received: by mail-yk0-x242.google.com with SMTP id v14so4482181ykd.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 13:26:52 -0800 (PST)
Date: Thu, 21 Jan 2016 16:26:51 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/5] Make cpuid <-> nodeid mapping persistent.
Message-ID: <20160121212651.GI5157@mtj.duckdns.org>
References: <1453357958-26941-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453357958-26941-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: cl@linux.com, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

Most changes being in ACPI, I think it probably would be a good idea
to cc Rafael and Len Brown.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
