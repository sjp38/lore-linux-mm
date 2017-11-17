Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 396976B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 02:30:59 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id v15so836249ote.10
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 23:30:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m126si933189oia.50.2017.11.16.23.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 23:30:58 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm: introduce MAP_FIXED_SAFE
References: <20171116101900.13621-1-mhocko@kernel.org>
 <20171116101900.13621-2-mhocko@kernel.org>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <a3f7aed9-0df2-2fd6-cebb-ba569ad66781@redhat.com>
Date: Fri, 17 Nov 2017 08:30:48 +0100
MIME-Version: 1.0
In-Reply-To: <20171116101900.13621-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-api@vger.kernel.org
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On 11/16/2017 11:18 AM, Michal Hocko wrote:
> +	if (flags & MAP_FIXED_SAFE) {
> +		struct vm_area_struct *vma = find_vma(mm, addr);
> +
> +		if (vma && vma->vm_start <= addr)
> +			return -ENOMEM;
> +	}

Could you pick a different error code which cannot also be caused by a 
an unrelated, possibly temporary condition?  Maybe EBUSY or EEXIST?

This would definitely help with application-based randomization of 
mappings, and there, actual ENOMEM and this error would have to be 
handled differently.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
