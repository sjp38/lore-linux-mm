Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,SUBJ_ALL_CAPS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E72E2C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 12:03:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A74CB20840
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 12:03:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A74CB20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54BCA6B0005; Tue, 13 Aug 2019 08:03:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FCA76B0006; Tue, 13 Aug 2019 08:03:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C4BD6B0007; Tue, 13 Aug 2019 08:03:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0061.hostedemail.com [216.40.44.61])
	by kanga.kvack.org (Postfix) with ESMTP id 147EE6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:03:03 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A1EF68248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:03:02 +0000 (UTC)
X-FDA: 75817268604.05.join32_71d258aa55a3a
X-HE-Tag: join32_71d258aa55a3a
X-Filterd-Recvd-Size: 4008
Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:03:02 +0000 (UTC)
Received: by mail-wm1-f44.google.com with SMTP id f72so1250318wmf.5
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:03:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=MX7X0Tdt4CfdX/yOLamRc+yoXtYLHnncZUmS/xCOMp0=;
        b=pKW/VyrW2s1IWNk32QO9BcyMNZJO05Jzmy2QsOrdwJxHeyqMxOOWz1XsYQ1vWMBZNi
         9s88oufSmN0ghn1wAPoba1Ksc09wDHaVoyVzuuqJJAe0RnYrsf07fZtddof81mn9C9Yb
         MHLH7w/BjM7sXWN2cAIUpnc52ABxdGso1y1byRfPYRldPYpJbHWnxPWGM4YCJ8zAtAmV
         eiS+Q3omroqCUZiusKcRHUp4Rrl4tHzJCElTfR7F4+9fkFhww/9FF1hUGS4jasRbVlM1
         7ZZMpW53Zw5xMDgVKvtlUXa14P+i6FEd2ILULbHOL9C2pY03ntGvIFLxdsK7YOJ3bDk4
         5zGQ==
X-Gm-Message-State: APjAAAWqjq0uwhb1OkzIWA29J6UZiw9JNeXPNb7rkxEuuX+fPkm0mZhM
	ondrq3LbZokj92S21X3EG1a8EA==
X-Google-Smtp-Source: APXvYqx63jmoFRwdi2jV2fOjTMCgfgZMJXNx+Msiu64sQdnLWei7VvJgxwF+ydu6THkk6ZGBzqYBBg==
X-Received: by 2002:a1c:c005:: with SMTP id q5mr2650468wmf.59.1565697780602;
        Tue, 13 Aug 2019 05:03:00 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:5193:b12b:f4df:deb6? ([2001:b07:6468:f312:5193:b12b:f4df:deb6])
        by smtp.gmail.com with ESMTPSA id p10sm1466831wma.8.2019.08.13.05.02.59
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 05:02:59 -0700 (PDT)
Subject: Re: DANGER WILL ROBINSON, DANGER
To: Matthew Wilcox <willy@infradead.org>
Cc: =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>,
 kvm@vger.kernel.org, linux-mm@kvack.org,
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
 <ae0d274c-96b1-3ac9-67f2-f31fd7bbdcee@redhat.com>
 <20190813112408.GC5307@bombadil.infradead.org>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <b6735416-602a-a2f5-5099-7e87c5162a6b@redhat.com>
Date: Tue, 13 Aug 2019 14:02:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190813112408.GC5307@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13/08/19 13:24, Matthew Wilcox wrote:
>>>
>>> This is an awfully big patch to the memory management code, buried in
>>> the middle of a gigantic series which almost guarantees nobody would
>>> look at it.  I call shenanigans.
>> Are you calling shenanigans on the patch submitter (which is gratuitous)
>> or on the KVM maintainers/reviewers?
>
> On the patch submitter, of course.  How can I possibly be criticising you
> for something you didn't do?

No idea.  "Nobody would look at it" definitely includes me though.

In any case, water under the bridge.  The submitter did duly mark the
series as RFC, I don't see anything wrong in what he did apart from not
having testcases. :)

Paolo

