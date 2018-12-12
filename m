Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1D88E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 01:44:46 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so12274523plb.18
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 22:44:46 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id h33si14544787plh.119.2018.12.11.22.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 22:44:45 -0800 (PST)
Subject: Re: [PATCH V2] kmemleak: Add config to select auto scan
References: <1540231723-7087-1-git-send-email-prpatel@nvidia.com>
 <20181029104320.GC168424@arrakis.emea.arm.com>
From: Prateek Patel <prpatel@nvidia.com>
Message-ID: <a51a7d4b-6366-ea10-f220-992525ec1d42@nvidia.com>
Date: Wed, 12 Dec 2018 12:14:29 +0530
MIME-Version: 1.0
In-Reply-To: <20181029104320.GC168424@arrakis.emea.arm.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-tegra@vger.kernel.org, snikam@nvidia.com, vdumpa@nvidia.com, talho@nvidia.com, swarren@nvidia.com, treding@nvidia.com

Hi Catalin,

Can you mark this patch as acknowledged so that it can be picked up by 
the maintainer.

Adding Andrew.

Thanks,

On 10/29/2018 4:13 PM, Catalin Marinas wrote:
> On Mon, Oct 22, 2018 at 11:38:43PM +0530, Prateek Patel wrote:
>> From: Sri Krishna chowdary <schowdary@nvidia.com>
>>
>> Kmemleak scan can be cpu intensive and can stall user tasks at times.
>> To prevent this, add config DEBUG_KMEMLEAK_AUTO_SCAN to enable/disable
>> auto scan on boot up.
>> Also protect first_run with DEBUG_KMEMLEAK_AUTO_SCAN as this is meant
>> for only first automatic scan.
>>
>> Signed-off-by: Sri Krishna chowdary <schowdary@nvidia.com>
>> Signed-off-by: Sachin Nikam <snikam@nvidia.com>
>> Signed-off-by: Prateek <prpatel@nvidia.com>
> Looks fine to me.
>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
