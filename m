Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 75E736B0038
	for <linux-mm@kvack.org>; Sat, 10 Oct 2015 16:57:34 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so107183520wic.1
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 13:57:34 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id b9si9965355wjy.159.2015.10.10.13.57.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Oct 2015 13:57:33 -0700 (PDT)
Received: by wijq8 with SMTP id q8so9361004wij.0
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 13:57:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <561976AC.6000003@redhat.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
	<20151010005622.17221.44373.stgit@dwillia2-desk3.jf.intel.com>
	<561976AC.6000003@redhat.com>
Date: Sat, 10 Oct 2015 13:57:32 -0700
Message-ID: <CAPcyv4jOtDfOZAQB7WN3MWQMPwkZmsZczrmK7=YxDy63ZRSiAw@mail.gmail.com>
Subject: Re: [PATCH v2 11/20] kvm: rename pfn_t to kvm_pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave@sr71.net>, Russell King <linux@arm.linux.org.uk>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, Marc Zyngier <marc.zyngier@arm.com>, Paul Mackerras <paulus@samba.org>, Christoffer Dall <christoffer.dall@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Alexander Graf <agraf@suse.com>

On Sat, Oct 10, 2015 at 1:35 PM, Paolo Bonzini <pbonzini@redhat.com> wrote:
> On 10/10/2015 02:56, Dan Williams wrote:
>> The core has developed a need for a "pfn_t" type [1].  Move the existing
>> pfn_t in KVM to kvm_pfn_t [2].
>>
>> [1]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002199.html
>> [2]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002218.html
>
> Can you please change also the other types in include/linux/kvm_types.h?

Hmm, all those seem kvm specific already.  I'd only prefix them with
kvm_ if they collided with a "core" type.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
