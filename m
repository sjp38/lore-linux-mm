Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8135EC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:35:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47B782067D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:35:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47B782067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD8B96B0006; Tue, 13 Aug 2019 10:35:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D88CB6B0007; Tue, 13 Aug 2019 10:35:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9FF06B0008; Tue, 13 Aug 2019 10:35:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id A98B56B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:35:32 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 56A9F180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:35:32 +0000 (UTC)
X-FDA: 75817652904.16.roof53_8791135bf9f0e
X-HE-Tag: roof53_8791135bf9f0e
X-Filterd-Recvd-Size: 5563
Received: from mail-wm1-f67.google.com (mail-wm1-f67.google.com [209.85.128.67])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:35:31 +0000 (UTC)
Received: by mail-wm1-f67.google.com with SMTP id 10so1744735wmp.3
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:35:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Lqxf8Z0rQTySZp3AWUTugOPDEfv/sn0v4AQtN6QyRsc=;
        b=BUg1KoBAUwql7r3SzZ/fOTvHD0IodvkamQvg+IZm3LzkEZ8qlmBf/m4PAMNVdqgWTp
         QgaEj7S3G2b+lewDTlB2b1dH+VmH4bKljKP48CQFzx/KGS2TAA/VUqMJ9lLJEzx11Niv
         g9nyLFBJhXmNfuXJUWsg4YwsS6yz0eRQQfAfrjHuLGhDyKo5FJkPVqq9VYq1CZgCt9O1
         Eq/15rzhN5E/MNa+E79BZjlvLVo0HS5wbcPC9XWW+EGj5fF3uaOc9+GGYNwgh9N2zuey
         BFKaPn8ClnMuaA2T5ZgkMCNZcoTrY3mgU3l3sj9mhO16fK+SAO2s/pFpmTrlbJbC4GUa
         DGDQ==
X-Gm-Message-State: APjAAAU8wwbUQNXY78pTFfLbwJHBCxd2b+ScYdM4eCFqo45tWgYb59uh
	AxmsMVOC4Wnp5QYK8XaTrithBg==
X-Google-Smtp-Source: APXvYqyMYCBhf8rY/MB9/wMH1QCr9Vu6nKQhVNm4wEsOIwP/ZmvzsrgT8mr1A8+NWxaviFXBe7iSWQ==
X-Received: by 2002:a1c:f618:: with SMTP id w24mr3674803wmc.112.1565706930235;
        Tue, 13 Aug 2019 07:35:30 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id r190sm3362812wmf.0.2019.08.13.07.35.29
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 07:35:29 -0700 (PDT)
Subject: Re: [RFC PATCH v6 75/92] kvm: x86: disable gpa_available optimization
 in emulator_read_write_onepage()
To: =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>,
 kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
 =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-76-alazar@bitdefender.com>
 <eb748e05-8289-0c05-6907-b6c898f6080b@redhat.com>
 <5d52ca22.1c69fb81.4ceb8.e90bSMTPIN_ADDED_BROKEN@mx.google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <5b6f78ca-a5c5-80c4-05af-cbf7fabb96b3@redhat.com>
Date: Tue, 13 Aug 2019 16:35:28 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <5d52ca22.1c69fb81.4ceb8.e90bSMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13/08/19 16:33, Adalbert Laz=C4=83r wrote:
> On Tue, 13 Aug 2019 10:47:34 +0200, Paolo Bonzini <pbonzini@redhat.com>=
 wrote:
>> On 09/08/19 18:00, Adalbert Laz=C4=83r wrote:
>>> If the EPT violation was caused by an execute restriction imposed by =
the
>>> introspection tool, gpa_available will point to the instruction point=
er,
>>> not the to the read/write location that has to be used to emulate the
>>> current instruction.
>>>
>>> This optimization should be disabled only when the VM is introspected=
,
>>> not just because the introspection subsystem is present.
>>>
>>> Signed-off-by: Adalbert Laz=C4=83r <alazar@bitdefender.com>
>>
>> The right thing to do is to not set gpa_available for fetch failures i=
n=20
>> kvm_mmu_page_fault instead:
>>
>> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
>> index 24843cf49579..1bdca40fa831 100644
>> --- a/arch/x86/kvm/mmu.c
>> +++ b/arch/x86/kvm/mmu.c
>> @@ -5364,8 +5364,12 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, g=
va_t cr2, u64 error_code,
>>  	enum emulation_result er;
>>  	bool direct =3D vcpu->arch.mmu->direct_map;
>> =20
>> -	/* With shadow page tables, fault_address contains a GVA or nGPA.  *=
/
>> -	if (vcpu->arch.mmu->direct_map) {
>> +	/*
>> +	 * With shadow page tables, fault_address contains a GVA or nGPA.
>> +	 * On a fetch fault, fault_address contains the instruction pointer.
>> +	 */
>> +	if (vcpu->arch.mmu->direct_map &&
>> +	    likely(!(error_code & PFERR_FETCH_MASK)) {
>>  		vcpu->arch.gpa_available =3D true;
>>  		vcpu->arch.gpa_val =3D cr2;
>>  	}
>
> Sure, but I think we'll have to extend the check.
>=20
> Searching the logs I've found:
>=20
>     kvm/x86: re-translate broken translation that caused EPT violation
>    =20
>     Signed-off-by: Mircea Cirjaliu <mcirjaliu@bitdefender.com>
>=20
>  arch/x86/kvm/x86.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> /home/b/kvmi@9cad844~1/arch/x86/kvm/x86.c:4757,4762 - /home/b/kvmi@9cad=
844/arch/x86/kvm/x86.c:4757,4763
>   	 */
>   	if (vcpu->arch.gpa_available &&
>   	    emulator_can_use_gpa(ctxt) &&
> + 	    (vcpu->arch.error_code & PFERR_GUEST_FINAL_MASK) &&
>   	    (addr & ~PAGE_MASK) =3D=3D (vcpu->arch.gpa_val & ~PAGE_MASK)) {
>   		gpa =3D vcpu->arch.gpa_val;
>   		ret =3D vcpu_is_mmio_gpa(vcpu, addr, gpa, write);
>=20

Yes, adding that check makes sense as well (still in kvm_mmu_page_fault).

Paolo

