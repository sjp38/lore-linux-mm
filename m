Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 515CD6B000D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 19:48:58 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id p91-v6so1977172plb.12
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 16:48:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f66-v6si4716312plb.103.2018.06.27.16.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Jun 2018 16:48:55 -0700 (PDT)
Subject: Re: [PATCHv4 18/18] x86: Introduce CONFIG_X86_INTEL_MKTME
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-19-kirill.shutemov@linux.intel.com>
 <ecf92475-93b4-295c-f1fc-7efba4843d98@infradead.org>
 <20180627215726.l5syzdcc26hgihtt@black.fi.intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <3a284a7a-821e-f539-0fe8-90f35cd8ff08@infradead.org>
Date: Wed, 27 Jun 2018 16:48:37 -0700
MIME-Version: 1.0
In-Reply-To: <20180627215726.l5syzdcc26hgihtt@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/27/2018 02:57 PM, Kirill A. Shutemov wrote:
> On Tue, Jun 26, 2018 at 05:30:12PM +0000, Randy Dunlap wrote:
>> On 06/26/2018 07:22 AM, Kirill A. Shutemov wrote:
>>> Add new config option to enabled/disable Multi-Key Total Memory
>>> Encryption support.
>>>
>>> MKTME uses MEMORY_PHYSICAL_PADDING to reserve enough space in per-KeyID
>>> direct mappings for memory hotplug.
>>>
>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> ---
>>>  arch/x86/Kconfig | 19 ++++++++++++++++++-
>>>  1 file changed, 18 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>>> index fa5e1ec09247..9a843bd63108 100644
>>> --- a/arch/x86/Kconfig
>>> +++ b/arch/x86/Kconfig
>>> @@ -1523,6 +1523,23 @@ config ARCH_USE_MEMREMAP_PROT
>>>  	def_bool y
>>>  	depends on AMD_MEM_ENCRYPT
>>>  
>>> +config X86_INTEL_MKTME
>>> +	bool "Intel Multi-Key Total Memory Encryption"
>>> +	select DYNAMIC_PHYSICAL_MASK
>>> +	select PAGE_EXTENSION
>>> +	depends on X86_64 && CPU_SUP_INTEL
>>> +	---help---
>>> +	  Say yes to enable support for Multi-Key Total Memory Encryption.
>>> +	  This requires an Intel processor that has support of the feature.
>>> +
>>> +	  Multikey Total Memory Encryption (MKTME) is a technology that allows
>>> +	  transparent memory encryption in and upcoming Intel platforms.
>>
>> huh?  Maybe drop the "and"?
> 
> Ugh.. It has to be "an".

an ... platform.
or
in upcoming Intel platforms.


-- 
~Randy
