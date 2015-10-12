Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 709B082F64
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:51:16 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so153682768pad.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 05:51:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id os5si25746401pab.233.2015.10.12.05.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 05:51:15 -0700 (PDT)
Subject: Re: [PATCH v2 11/20] kvm: rename pfn_t to kvm_pfn_t
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
 <20151010005622.17221.44373.stgit@dwillia2-desk3.jf.intel.com>
 <561976AC.6000003@redhat.com>
 <CAPcyv4jOtDfOZAQB7WN3MWQMPwkZmsZczrmK7=YxDy63ZRSiAw@mail.gmail.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <561BACB8.7020405@redhat.com>
Date: Mon, 12 Oct 2015 14:51:04 +0200
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jOtDfOZAQB7WN3MWQMPwkZmsZczrmK7=YxDy63ZRSiAw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Dave Hansen <dave@sr71.net>, Russell King <linux@arm.linux.org.uk>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, Marc Zyngier <marc.zyngier@arm.com>, Paul Mackerras <paulus@samba.org>, Christoffer Dall <christoffer.dall@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Alexander Graf <agraf@suse.com>, KVM list <kvm@vger.kernel.org>



On 10/10/2015 22:57, Dan Williams wrote:
> On Sat, Oct 10, 2015 at 1:35 PM, Paolo Bonzini <pbonzini@redhat.com> wrote:
>> On 10/10/2015 02:56, Dan Williams wrote:
>>> The core has developed a need for a "pfn_t" type [1].  Move the existing
>>> pfn_t in KVM to kvm_pfn_t [2].
>>>
>>> [1]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002199.html
>>> [2]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002218.html
>>
>> Can you please change also the other types in include/linux/kvm_types.h?
> 
> Hmm, all those seem kvm specific already.  I'd only prefix them with
> kvm_ if they collided with a "core" type.

But they are all related and the code becomes uglier if you only prefix
one of them.  If you don't convert all of them, I will do it anyway as
soon as this patch get in.

Since it touches a lot of KVM files, we should synchronize in order to
avoid conflicts and gnashing of teeth.  What tree is this patch going
in?  You could provide me a commit SHA1 for this patch (well, its
definitive version) based on Linus's tree (so that I can merge it in my
tree as well), or I could commit it and provide the SHA1 to the
maintainer of said tree.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
