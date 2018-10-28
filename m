Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDC826B0347
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 03:05:32 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id s70so6567352qks.4
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 00:05:32 -0700 (PDT)
Received: from sonic301-20.consmr.mail.ir2.yahoo.com (sonic301-20.consmr.mail.ir2.yahoo.com. [77.238.176.97])
        by mx.google.com with ESMTPS id 25si5229161qkz.65.2018.10.28.00.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Oct 2018 00:05:32 -0700 (PDT)
Subject: Re: [PATCH] mm: simplify get_next_ra_size
References: <1540707206-19649-1-git-send-email-hsiangkao@aol.com>
 <20181028062722.hfomc3davarmzojw@wfg-t540p.sh.intel.com>
From: Gao Xiang <hsiangkao@aol.com>
Message-ID: <17e85309-e324-6c0f-6da2-2c4f0703a464@aol.com>
Date: Sun, 28 Oct 2018 15:05:20 +0800
MIME-Version: 1.0
In-Reply-To: <20181028062722.hfomc3davarmzojw@wfg-t540p.sh.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Fengguang,

On 2018/10/28 14:27, Fengguang Wu wrote:
> LooksA goodA toA me,A thanks!
> 
> Reviewed-by:A FengguangA WuA <fengguang.wu@intel.com>

Thanks for taking time and the quickly review. :)

Best regards,
Gao Xiang

> 
> OnA Sun,A OctA 28,A 2018A atA 02:13:26PMA +0800,A GaoA XiangA wrote:
>> It'sA aA trivialA simplificationA forA get_next_ra_sizeA and
>> clearA enoughA forA humansA toA understand.
>>
>> ItA alsoA fixesA potentialA overflowA ifA ra->size(<A ra_pages)A isA tooA large.
>>
>> Cc:A FengguangA WuA <fengguang.wu@intel.com>
>> Signed-off-by:A GaoA XiangA <hsiangkao@aol.com>
>> --- 
