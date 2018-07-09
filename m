Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 475606B032C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:44:37 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x2-v6so10646770plv.0
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:44:37 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 29-v6si6412129pgv.292.2018.07.09.11.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:44:36 -0700 (PDT)
Subject: Re: [PATCHv4 18/18] x86: Introduce CONFIG_X86_INTEL_MKTME
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-19-kirill.shutemov@linux.intel.com>
 <20180709183656.GK6873@char.US.ORACLE.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d9edff3d-64bd-be81-c9fd-52699d7da81e@intel.com>
Date: Mon, 9 Jul 2018 11:44:33 -0700
MIME-Version: 1.0
In-Reply-To: <20180709183656.GK6873@char.US.ORACLE.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/09/2018 11:36 AM, Konrad Rzeszutek Wilk wrote:
> On Tue, Jun 26, 2018 at 05:22:45PM +0300, Kirill A. Shutemov wrote:
> Rip out the X86?
>> +	bool "Intel Multi-Key Total Memory Encryption"
>> +	select DYNAMIC_PHYSICAL_MASK
>> +	select PAGE_EXTENSION
> 
> And maybe select 5-page?

Why?  It's not a strict dependency.  You *can* build a 4-level kernel
and run it on smaller systems.

>> +	depends on X86_64 && CPU_SUP_INTEL
>> +	---help---
>> +	  Say yes to enable support for Multi-Key Total Memory Encryption.
>> +	  This requires an Intel processor that has support of the feature.
>> +
>> +	  Multikey Total Memory Encryption (MKTME) is a technology that allows
>> +	  transparent memory encryption in and upcoming Intel platforms.
> 
> How about saying which CPUs? Or just dropping this?

We don't have any information about specifically which processors with
have this feature to share.  But, this config text does tell someone
that they can't use this feature on today's platforms.

We _did_ say this for previous features (protection keys stands out
where we said it was for "Skylake Servers" IIRC), but we are not yet
able to do the same for this feature.
