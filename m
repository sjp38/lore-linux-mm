Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6853C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:34:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B255320840
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:34:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B255320840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FCA36B0005; Tue, 13 Aug 2019 05:34:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AD176B0006; Tue, 13 Aug 2019 05:34:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19C8A6B0007; Tue, 13 Aug 2019 05:34:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0054.hostedemail.com [216.40.44.54])
	by kanga.kvack.org (Postfix) with ESMTP id E5D6F6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:34:07 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8B3DB8248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:34:07 +0000 (UTC)
X-FDA: 75816893334.05.crib74_7b45aaffa3d4c
X-HE-Tag: crib74_7b45aaffa3d4c
X-Filterd-Recvd-Size: 4742
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com [209.85.128.66])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:34:07 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id o4so716161wmh.2
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:34:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=udqo7kROlqFqisXj5oz1sWF1oRTaX6uM+TM5JcYIbqE=;
        b=W0DxQNymAJL4jI/IcOHlRoHgtaqyrDHhFpZLul4210a8Ov6hqu10FCrClOZso7njj1
         fPZB18IRLhr9CgXvfWhw0+xQ5So9SSrV/vJtJyEriGAKQ5/5eTwbd3tiRHDy1GDcJgpx
         bdo4Te/EmgTOm9k2mtiHEbQpa1ujbgCCCEgu0ghgUYCW6nOK4hNY0vz9PoOY/88YOziQ
         moH998cfIdmEsTJp/I1bUQDRZyOttdDDxQm4y8NZCdGDdprAZZMm9q25zeOnF+q9uqin
         /xRst1fw6dwf2WSiMW/EpHSdTqmvI0gSnkkM1+/PWkMh1MJ1AHO64vnWrBeMNDMIJyT6
         3e4Q==
X-Gm-Message-State: APjAAAW2VpypKTTzlFphwgATvg3004152bh4rO33Gl+YMQlvERbz05YA
	qPdpiXQx17CDRaLlaG6KMyCmxQ==
X-Google-Smtp-Source: APXvYqxoXSubblXg/ubxv7gJT3sw06cSBwphouvlACdbw0oLuVuxziG5Y6exA/d83ei6Qsn3CzcqSw==
X-Received: by 2002:a1c:4d05:: with SMTP id o5mr1991136wmh.129.1565688845929;
        Tue, 13 Aug 2019 02:34:05 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id r23sm996180wmc.38.2019.08.13.02.34.04
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:34:05 -0700 (PDT)
Subject: Re: [RFC PATCH v6 00/92] VM introspection
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
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <a048da21-0b30-8615-a6e5-f3e8f45e7920@redhat.com>
Date: Tue, 13 Aug 2019 11:34:03 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
>=20
> Patches 1-20: unroll a big part of the KVM introspection subsystem,
> sent in one patch in the previous versions.
>=20
> Patches 21-24: extend the current page tracking code.
>=20
> Patches 25-33: make use of page tracking to support the
> KVMI_SET_PAGE_ACCESS introspection command and the KVMI_EVENT_PF event
> (on EPT violations caused by the tracking settings).
>=20
> Patches 34-42: include the SPP feature (Enable Sub-page
> Write Protection Support), already sent to KVM list:
>=20
> 	https://lore.kernel.org/lkml/20190717133751.12910-1-weijiang.yang@inte=
l.com/
>=20
> Patches 43-46: add the commands needed to use SPP.
>=20
> Patches 47-63: unroll almost all the rest of the introspection code.
>=20
> Patches 64-67: add single-stepping, mostly as a way to overcome the
> unimplemented instructions, but also as a feature for the introspection
> tool.
>=20
> Patches 68-70: cover more cases related to EPT violations.
>=20
> Patches 71-73: add the remote mapping feature, allowing the introspecti=
on
> tool to map into its address space a page from guest memory.
>=20
> Patches 74: add a fix to hypercall emulation.
>=20
> Patches 75-76: disable some features/optimizations when the introspecti=
on
> code is present.
>=20
> Patches 77-78: add trace functions for the introspection code and chang=
e
> some related to interrupts/exceptions injection.
>=20
> Patches 79-92: new instruction for the x86 emulator, including cmpxchg
> fixes.

Thanks for the very good explanation.  Apart from the complicated flow
of KVM request handling and KVM reply, the main issue is the complete
lack of testcases.  There should be a kvmi_test in
tools/testing/selftests/kvm, and each patch adding a new ioctl or event
should add a new testcase.

Paolo

