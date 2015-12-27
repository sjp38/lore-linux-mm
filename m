Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 97C9282FCE
	for <linux-mm@kvack.org>; Sat, 26 Dec 2015 19:31:27 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id to18so122292904igc.0
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 16:31:27 -0800 (PST)
Received: from g2t4621.austin.hp.com (g2t4621.austin.hp.com. [15.73.212.80])
        by mx.google.com with ESMTPS id i12si28036500igt.91.2015.12.26.16.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Dec 2015 16:31:27 -0800 (PST)
Subject: Re: [PATCH v2 14/16] x86,nvdimm,kexec: Use walk_iomem_res_desc() for
 iomem search
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
 <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
 <20151226103804.GB21988@pd.tnic>
From: Toshi Kani <toshi.kani@hpe.com>
Message-ID: <567F315B.8080005@hpe.com>
Date: Sat, 26 Dec 2015 17:31:23 -0700
MIME-Version: 1.0
In-Reply-To: <20151226103804.GB21988@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, linux-arch@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, x86@kernel.org, linux-nvdimm@lists.01.org

+ cc: kexec list

On 12/26/2015 3:38 AM, Borislav Petkov wrote:
> On Fri, Dec 25, 2015 at 03:09:23PM -0700, Toshi Kani wrote:
>> Change to call walk_iomem_res_desc() for searching resource entries
>> with the following names:
>>   "ACPI Tables"
>>   "ACPI Non-volatile Storage"
>>   "Persistent Memory (legacy)"
>>   "Crash kernel"
>>
>> Note, the caller of walk_iomem_res() with "GART" is left unchanged
>> because this entry may be initialized by out-of-tree drivers, which
>> do not have 'desc' set to IORES_DESC_GART.
>
> There's this out-of-tree bogus argument again. :\
>
> Why do we care about out-of-tree drivers?
>
> You can just as well fix the "GART" case too and kill walk_iomem_res()
> altogether...

Right, but I do not see any "GART" case in the upstream code, so I 
cannot change it...

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
