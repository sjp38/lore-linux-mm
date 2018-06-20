Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFAE16B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:44:57 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id y7-v6so551080plt.17
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:44:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q18-v6si2804027pgd.294.2018.06.20.15.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Jun 2018 15:44:56 -0700 (PDT)
Subject: Re: [PATCH 1/3] vmalloc: Add __vmalloc_node_try_addr function
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
 <1529532570-21765-2-git-send-email-rick.p.edgecombe@intel.com>
 <12014310-19f7-dc31-d983-9c7e00c8b446@infradead.org>
 <CAGXu5j+RgbMKqiBcsWMOZ-ci-rT19imgCoHtPKgDURF1tC+COg@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <778b2a1b-d810-815b-0fba-8a1d191acd49@infradead.org>
Date: Wed, 20 Jun 2018 15:44:51 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+RgbMKqiBcsWMOZ-ci-rT19imgCoHtPKgDURF1tC+COg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, kristen Accardi <kristen.c.accardi@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Van De Ven, Arjan" <arjan.van.de.ven@intel.com>

On 06/20/2018 03:35 PM, Kees Cook wrote:
> On Wed, Jun 20, 2018 at 3:16 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
>> On 06/20/2018 03:09 PM, Rick Edgecombe wrote:
>>> +void *__vmalloc_node_try_addr(unsigned long addr, unsigned long size,
>>> +                     gfp_t gfp_mask, pgprot_t prot, unsigned long vm_flags,
>>> +                     int node, const void *caller)
>>> +{
>>
>> so this isn't optional, eh?  You are going to force it on people because?
> 
> RANDOMIZE_BASE isn't optional either. :) This improves the module
> address entropy with (what seems to be) no down-side, so yeah, I think
> it should be non-optional. :)

In what kernel tree is RANDOMIZE_BASE not optional?

x86:
config RANDOMIZE_BASE
	bool "Randomize the address of the kernel image (KASLR)"
	depends on RELOCATABLE
	default y

mips:
config RANDOMIZE_BASE
	bool "Randomize the address of the kernel image"
	depends on RELOCATABLE

arm64:
config RANDOMIZE_BASE
	bool "Randomize the address of the kernel image"
	select ARM64_MODULE_PLTS if MODULES
	select RELOCATABLE


thanks,
-- 
~Randy
