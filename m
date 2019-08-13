Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE65EC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:11:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8366A20663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:11:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8366A20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 334EA6B0269; Tue, 13 Aug 2019 05:11:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E5896B026A; Tue, 13 Aug 2019 05:11:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AEE26B026B; Tue, 13 Aug 2019 05:11:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0076.hostedemail.com [216.40.44.76])
	by kanga.kvack.org (Postfix) with ESMTP id EDC8F6B0269
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:11:14 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9F5928248AA2
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:11:14 +0000 (UTC)
X-FDA: 75816835668.02.wash79_44fe77d867b26
X-HE-Tag: wash79_44fe77d867b26
X-Filterd-Recvd-Size: 4191
Received: from mail-wr1-f67.google.com (mail-wr1-f67.google.com [209.85.221.67])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:11:13 +0000 (UTC)
Received: by mail-wr1-f67.google.com with SMTP id p17so107028310wrf.11
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:11:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ZLfQUKMyIX+ZNqu061niPgB5QJHAS9O4tJDY0/iOqpI=;
        b=XBt0YJKkZqK/K70G6hIUgvJG6P22z7dyEixZWnXJIU9tQDd0E+amIhCHtBbSjUraHl
         Aj91hWOj2hfaVLC2mQdJ+LbFQVMBrBn2dh2r+4u1UczC5etcRrS5sV4TgAKeW7pM51hd
         O4pufb8VEMt0OJMNhznmmFwqp3FJJ+DxFVKHNF2HspY8+ODK/N330Yw2/zPG4gqmPU+E
         B+2LC9+BqcaW4yOVhGHhUd+LcXP/JDHv98agPI9ssjlkbyPnHqKK3KTcF9/pxtlmvMfu
         PNu8jP2dmaSTMdBjaB90lFc5rn5UYnlL7CHhrmVkpk1RNRdoV5ZJmVTae+Jd900e2NPQ
         7k1g==
X-Gm-Message-State: APjAAAUIFeDUz6Qfx991GodBlZIB595/NkEIrJ/g5vS9KRFgeJkMoEV7
	loHpE0Mi7g9GB7i8IafmDpmsGcm8jEo=
X-Google-Smtp-Source: APXvYqy7VmidnHameXLpWAVfWnBv9skdiBmqhQxOPN9tWRfiYQG3zhEjwfDUfIpUfac5Z2c42ezw5A==
X-Received: by 2002:a5d:4f01:: with SMTP id c1mr20624055wru.43.1565687472832;
        Tue, 13 Aug 2019 02:11:12 -0700 (PDT)
Received: from [192.168.10.150] ([93.56.166.5])
        by smtp.gmail.com with ESMTPSA id x24sm898079wmh.5.2019.08.13.02.11.11
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:11:12 -0700 (PDT)
Subject: Re: [RFC PATCH v6 01/92] kvm: introduce KVMI (VM introspection
 subsystem)
To: Sean Christopherson <sean.j.christopherson@intel.com>,
 =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>
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
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <81f6c33e-6851-8272-bd8e-7b0bf9ef1ff9@redhat.com>
Date: Tue, 13 Aug 2019 11:11:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190812202030.GB1437@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/08/19 22:20, Sean Christopherson wrote:
> The refcounting approach seems a bit backwards, and AFAICT is driven by
> implementing unhook via a message, which also seems backwards.  I assume
> hook and unhook are relatively rare events and not performance critical,
> so make those the restricted/slow flows, e.g. force userspace to quiesce
> the VM by making unhook() mutually exclusive with every vcpu ioctl() and
> maybe anything that takes kvm->lock. 

The reason for the unhook event, as far as I understand, is because the
introspection appliance can poke int3 into the guest and needs an
opportunity to undo that.

I don't have a big problem with that and the refcounting, at least for
this first iteration---it can be tackled later, once the general event
loop is simplified---however I agree with the other comments that Sean
made.  Fortunately it should not be hard to apply them to the whole
patchset with search and replace on the patches themselves.

Paolo

