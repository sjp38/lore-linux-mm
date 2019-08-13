Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,SUBJ_ALL_CAPS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBC70C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:29:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 850DF20673
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:29:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 850DF20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3272E6B0005; Tue, 13 Aug 2019 05:29:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D86F6B0006; Tue, 13 Aug 2019 05:29:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EF0D6B0007; Tue, 13 Aug 2019 05:29:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0037.hostedemail.com [216.40.44.37])
	by kanga.kvack.org (Postfix) with ESMTP id F26006B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:29:12 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9A9C4180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:29:12 +0000 (UTC)
X-FDA: 75816880944.13.hook29_504fd6f2ea827
X-HE-Tag: hook29_504fd6f2ea827
X-Filterd-Recvd-Size: 4340
Received: from mail-wm1-f67.google.com (mail-wm1-f67.google.com [209.85.128.67])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:29:11 +0000 (UTC)
Received: by mail-wm1-f67.google.com with SMTP id 207so839930wma.1
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:29:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=HlAEpqymIE/2aXmWh9O2C6f1zWhZyF+vIZxr8hLy7E8=;
        b=h+uazs3x/Oo/Em2IIX/wF2dDWW7vCGsxvkk9yHXp3ub/m6ALJNSOGWARltwHR4+zLK
         8ygGAV5kGAnxXO31CD6l3twGaHTIUFMJE1I3svGPdIQ3oFJQOyhaB4XKlRAV3d7M9iKy
         KbuGW5wkeuj50Z5i2CZEPAd7Widbsl/3E0M3NpM859KsXRJJtcNuGQAsPiPPmx8bmq73
         yOyOJMl/9wlYOSyQ4YA6Wvw7vkufXZtzWrH4T+Jug7Eg6ItVciWhqBLX2bLlKmJKg2HF
         cojlbneQi9skBpLiBEsO74AUJfw0JHWg+6ksrJ92bmu5qof3t62h4mHaZzQsRiiZpXzh
         wJnw==
X-Gm-Message-State: APjAAAVj82/7IrqQ/qAjgTh462wMZQW2s3YS/88V+TDmgSxSjeTJJSMU
	faPpQZhiYOuYLkmlIqRA0pIm+w==
X-Google-Smtp-Source: APXvYqzrOiKUATXICk0r/wqqOqYzdUlD6b5RE1HxjJCFGhp5IL3oELH2ehl1knzxc0AKbs6tiQAFDw==
X-Received: by 2002:a7b:c198:: with SMTP id y24mr2019539wmi.131.1565688550614;
        Tue, 13 Aug 2019 02:29:10 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5d12:7fa9:fb2d:7edb? ([2001:b07:6468:f312:5d12:7fa9:fb2d:7edb])
        by smtp.gmail.com with ESMTPSA id f134sm1257977wmg.20.2019.08.13.02.29.09
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 02:29:10 -0700 (PDT)
Subject: Re: DANGER WILL ROBINSON, DANGER
To: Matthew Wilcox <willy@infradead.org>,
 =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
 virtualization@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?=
 <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
 Yu C <yu.c.zhang@intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?=
 <mdontu@bitdefender.com>, =?UTF-8?Q?Mircea_C=c3=aerjaliu?=
 <mcirjaliu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-72-alazar@bitdefender.com>
 <20190809162444.GP5482@bombadil.infradead.org>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <ae0d274c-96b1-3ac9-67f2-f31fd7bbdcee@redhat.com>
Date: Tue, 13 Aug 2019 11:29:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809162444.GP5482@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/19 18:24, Matthew Wilcox wrote:
> On Fri, Aug 09, 2019 at 07:00:26PM +0300, Adalbert Laz=C4=83r wrote:
>> +++ b/include/linux/page-flags.h
>> @@ -417,8 +417,10 @@ PAGEFLAG(Idle, idle, PF_ANY)
>>   */
>>  #define PAGE_MAPPING_ANON	0x1
>>  #define PAGE_MAPPING_MOVABLE	0x2
>> +#define PAGE_MAPPING_REMOTE	0x4
> Uh.  How do you know page->mapping would otherwise have bit 2 clear?
> Who's guaranteeing that?
>=20
> This is an awfully big patch to the memory management code, buried in
> the middle of a gigantic series which almost guarantees nobody would
> look at it.  I call shenanigans.

Are you calling shenanigans on the patch submitter (which is gratuitous)
or on the KVM maintainers/reviewers?

It's not true that nobody would look at it.  Of course no one from
linux-mm is going to look at it, but the maintainer that looks at the
gigantic series is very much expected to look at it and explain to the
submitter that this patch is unacceptable as is.

In fact I shouldn't have to to explain this to you; you know better than
believing that I would try to sneak it past the mm folks.  I am puzzled.

Paolo

