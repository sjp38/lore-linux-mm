Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id EF5D782FCE
	for <linux-mm@kvack.org>; Sat, 26 Dec 2015 19:52:10 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id o124so160025303oia.1
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 16:52:10 -0800 (PST)
Received: from g1t6220.austin.hp.com (g1t6220.austin.hp.com. [15.73.96.84])
        by mx.google.com with ESMTPS id i6si24984668obk.65.2015.12.26.16.52.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Dec 2015 16:52:10 -0800 (PST)
Subject: Re: [PATCH v2 15/16] checkpatch: Add warning on deprecated
 walk_iomem_res
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
 <1451081365-15190-15-git-send-email-toshi.kani@hpe.com>
 <1451088307.12498.3.camel@perches.com>
From: Toshi Kani <toshi.kani@hpe.com>
Message-ID: <567F3638.7050008@hpe.com>
Date: Sat, 26 Dec 2015 17:52:08 -0700
MIME-Version: 1.0
In-Reply-To: <1451088307.12498.3.camel@perches.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>, akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@canonical.com>

On 12/25/2015 5:05 PM, Joe Perches wrote:
> On Fri, 2015-12-25 at 15:09 -0700, Toshi Kani wrote:
>> Use of walk_iomem_res() is deprecated in new code.  Change
>> checkpatch.pl to check new use of walk_iomem_res() and suggest
>> to use walk_iomem_res_desc() instead.
> []
>> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> []
>> @@ -3424,6 +3424,12 @@ sub process {
>>   			}
>>   		}
>>
>> +# check for uses of walk_iomem_res()
>> +		if ($line =~ /\bwalk_iomem_res\(/) {
>> +			WARN("walk_iomem_res",
>> +			     "Use of walk_iomem_res is deprecated, please use walk_iomem_res_desc instead\n" . $herecurr)
>> +		}
>> +
>>   # check for new typedefs, only function parameters and sparse annotations
>>   # make sense.
>>   		if ($line =~ /\btypedef\s/ &&
>
> There are 6 uses of this function in the entire kernel tree.
> Why not just change them, remove the function and avoid this?

Sorry, I should have put some background in the description.  We have 
discussed if we can remove walk_iomem_res() in the thread below.
https://lkml.org/lkml/2015/12/23/248

But this may depend on how we deal with the last remaining caller, 
walk_iomem_res() with "GART", being discussed in the thread below.  I 
will update according to the outcome.
https://lkml.org/lkml/2015/12/26/144

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
