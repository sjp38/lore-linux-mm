Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBE2A6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 20:47:31 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o2-v6so2073797plk.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 17:47:31 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id p85si8761281pfk.77.2018.04.06.17.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 17:47:30 -0700 (PDT)
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172727.025EBF16@viggo.jf.intel.com>
 <20180407000943.GA15890@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6e3f8e1c-afed-64de-9815-8478e18532aa@intel.com>
Date: Fri, 6 Apr 2018 17:47:29 -0700
MIME-Version: 1.0
In-Reply-To: <20180407000943.GA15890@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, shakeelb@google.com, stable@kernel.org, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On 04/06/2018 05:09 PM, Ram Pai wrote:
>> -	/*
>> -	 * Look for a protection-key-drive execute-only mapping
>> -	 * which is now being given permissions that are not
>> -	 * execute-only.  Move it back to the default pkey.
>> -	 */
>> -	if (vma_is_pkey_exec_only(vma) &&
>> -	    (prot & (PROT_READ|PROT_WRITE))) {
>> -		return 0;
>> -	}
>> +
> Dave,
> 	this can be simply:
> 
> 	if ((vma_is_pkey_exec_only(vma) && (prot != PROT_EXEC))
> 		return ARCH_DEFAULT_PKEY;

Yes, but we're removing that code entirely. :)
