Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 344A76B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 14:56:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t8so243069070oif.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 11:56:47 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id p6si25557522pap.46.2016.06.14.11.56.46
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 11:56:46 -0700 (PDT)
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
 <57603DC0.9070607@linux.intel.com>
 <20160614193407.1470d998@lxorguk.ukuu.org.uk>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <576052E0.3050408@linux.intel.com>
Date: Tue, 14 Jun 2016 11:54:24 -0700
MIME-Version: 1.0
In-Reply-To: <20160614193407.1470d998@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, hpa@zytor.com, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com, Borislav Petkov <bp@alien8.de>

On 06/14/2016 11:34 AM, One Thousand Gnomes wrote:
> On Tue, 14 Jun 2016 10:24:16 -0700
> Dave Hansen <dave.hansen@linux.intel.com> wrote:
> 
>> On 06/14/2016 10:01 AM, Lukasz Anaczkowski wrote:
>>> v2 (Lukasz Anaczkowski):
>>>     () fixed compilation breakage  
>> ...
>>
>> By unconditionally defining the workaround code, even on kernels where
>> there is no chance of ever hitting this bug.  I think that's a pretty
>> poor way to do it.
>>
>> Can we please stick this in one of the intel.c files, so it's only
>> present on CPU_SUP_INTEL builds?
> 
> Can we please make it use alternatives or somesuch so that it just goes
> away at boot if its not a Knights Landing box ?

Lukasz, Borislav suggested using static_cpu_has_bug(), which will do the
alternatives patching.  It's definitely the right thing to use here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
