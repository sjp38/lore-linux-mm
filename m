Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4FB6B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 13:39:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n2so2689798pgs.2
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:39:13 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id s76si3197004pfi.412.2018.03.26.10.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 10:39:12 -0700 (PDT)
Subject: Re: [PATCH 1/9] x86, pkeys: do not special case protection key 0
References: <20180323180903.33B17168@viggo.jf.intel.com>
 <20180323180905.B40984E6@viggo.jf.intel.com>
 <20180326173522.GB5743@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e63d1ea6-4a1e-063c-6cc0-ad80fb554515@intel.com>
Date: Mon, 26 Mar 2018 10:39:09 -0700
MIME-Version: 1.0
In-Reply-To: <20180326173522.GB5743@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On 03/26/2018 10:35 AM, Ram Pai wrote:
>>  #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
>>  	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
>> -		/* pkey 0 is the default and always allocated */
>> +		/* pkey 0 is the default and allocated implicitly */
>>  		mm->context.pkey_allocation_map = 0x1;
> In the second patch, you introduce DEFAULT_KEY. Maybe you 
> should introduce here and express the above code as
> 
> 		mm->context.pkey_allocation_map = (0x1 << DEFAULT_KEY);
> 
> Incase your default key changes to something else, you are still good.

That's a good cleanup, but I'd rather limit _this_ set to bug fixes.
