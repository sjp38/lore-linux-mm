Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8026B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 14:22:05 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w102so3800960wrb.17
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:22:05 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 132si4229638wmh.131.2017.04.27.11.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 11:22:04 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id y10so6374096wmh.0
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:22:04 -0700 (PDT)
Subject: Re: [PATCH v2 1/3] mm: Silence vmap() allocation failures based on
 caller gfp_flags
References: <20170427173900.2538-1-f.fainelli@gmail.com>
 <20170427173900.2538-2-f.fainelli@gmail.com>
 <20170427175653.GB30672@dhcp22.suse.cz>
 <416a788c-6160-1ce8-fccc-839f719b2a88@gmail.com>
 <20170427182018.GC30672@dhcp22.suse.cz>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <6f8480e5-5993-4b9c-2c28-0996ce4b0d81@gmail.com>
Date: Thu, 27 Apr 2017 11:21:57 -0700
MIME-Version: 1.0
In-Reply-To: <20170427182018.GC30672@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On 04/27/2017 11:20 AM, Michal Hocko wrote:
>>> would be shorter and you wouldn't need the goto and a label.
>>
>> Do you want me to resubmit with that change included?
> 
> Up to you. As I've said this is a nit at best.

I just sent a v3 based on feedback from Ard, thanks!
-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
