Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8953EC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 10:37:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50F252084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 10:37:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50F252084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4D8F6B0005; Wed, 14 Aug 2019 06:37:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFEAB6B0006; Wed, 14 Aug 2019 06:37:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CED416B0007; Wed, 14 Aug 2019 06:37:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id AD4A06B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 06:37:55 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 543EB18C9
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:37:55 +0000 (UTC)
X-FDA: 75820682910.10.bird95_ad187fa63e03
X-HE-Tag: bird95_ad187fa63e03
X-Filterd-Recvd-Size: 4198
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com [209.85.221.65])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:37:54 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id b16so13899898wrq.9
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 03:37:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=oVgEV1g/UPelVsZcKcw9nOSje8rWLBWULtBtVoDSjso=;
        b=QS1AqVYvq60Ww60u+CMlSUq1Fza3uVN1zB699K0p99rDuO3XMjtrbUUaI92hieddmo
         AGEdGmn4+RDA746U34lnlql+zgOxG3mbR4vrRYIFhtP9NhG2ZBPu8moffL4HfzrFkYL3
         axf7eUPBW2UxBuOJq2Kgh5dOnYNGpG88TRXGx2NiQFsR27uuk2mwk+unTQKNrlTeeVRd
         /+1Nrkg1NMDZdIgO3I+pjU6eamEfAjO0nAyVvIYOzq+KT0TBFB4+c4GUeUI0XdWQtJ6d
         Hr2WdO/54mr/133h87STqcs9NRALISJRyAar3AQmwyGqYfgOYgUQ9prYjFbjyDp7Oo6U
         85BA==
X-Gm-Message-State: APjAAAX6LKREPOfUv64XltFhMJ7bds/fBplHTbHM5AYwfAhB0t0Nuifo
	a/8hQNJHKAIq7dhNgbntDAiLWw==
X-Google-Smtp-Source: APXvYqxPmIpqR9ZiKdjUNFmTa5cEt4XtlN46WXuRKyGyJO3GD/9oZYwpSywYiNiWytLJB09hSTpO/w==
X-Received: by 2002:adf:ed4a:: with SMTP id u10mr55236024wro.284.1565779072995;
        Wed, 14 Aug 2019 03:37:52 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:2cae:66cd:dd43:92d9? ([2001:b07:6468:f312:2cae:66cd:dd43:92d9])
        by smtp.gmail.com with ESMTPSA id a17sm2983732wmm.47.2019.08.14.03.37.51
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Aug 2019 03:37:52 -0700 (PDT)
Subject: Re: [RFC PATCH v6 01/92] kvm: introduce KVMI (VM introspection
 subsystem)
To: =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>,
 Sean Christopherson <sean.j.christopherson@intel.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
 virtualization@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?=
 <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>, Zhang@vger.kernel.org,
 Yu C <yu.c.zhang@intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?=
 <mdontu@bitdefender.com>, =?UTF-8?Q?Mircea_C=c3=aerjaliu?=
 <mcirjaliu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-2-alazar@bitdefender.com>
 <20190812202030.GB1437@linux.intel.com>
 <5d52a5ae.1c69fb81.5c260.1573SMTPIN_ADDED_BROKEN@mx.google.com>
 <5fa6bd89-9d02-22cd-24a8-479abaa4f788@redhat.com>
 <20190813150128.GB13991@linux.intel.com>
 <5d53d8d1.1c69fb81.7d32.0bedSMTPIN_ADDED_BROKEN@mx.google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <e00a35b2-74ca-41b8-77a0-2cd37f55a8b6@redhat.com>
Date: Wed, 14 Aug 2019 12:37:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <5d53d8d1.1c69fb81.7d32.0bedSMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/08/19 11:48, Adalbert Laz=C4=83r wrote:
>> Why does closing the socket require destroying the kvmi object?  E.g. =
can
>> it be marked as defunct or whatever and only fully removed on a synchr=
onous
>> unhook from userspace?  Re-hooking could either require said unhook, o=
r
>> maybe reuse the existing kvmi object with a new socket.
> Will it be better to have the following ioctls?
>=20
>   - hook (alloc kvmi and kvmi_vcpu structs)
>   - notify_imminent_unhook (send the KVMI_EVENT_UNHOOK event)
>   - unhook (free kvmi and kvmi_vcpu structs)

Yeah, that is nice also because it leaves the timeout policy to
userspace.  (BTW, please change references to QEMU to "userspace").

Paolo

