Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7159DC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:58:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 216652077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:58:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 216652077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0A6D8E0003; Tue, 12 Mar 2019 15:58:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB8ED8E0002; Tue, 12 Mar 2019 15:58:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 981C08E0003; Tue, 12 Mar 2019 15:58:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75CCF8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:58:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 23so2725148qkl.16
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:58:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=T3dIU6k3ikBdNxmUckxy77ienly2WxhsLcwRGC+ABT4=;
        b=QEAP1gVbj5lZ18f8lnoj4rQjTf+45iqNvjPjNMR5pgrGeATLpKLsAjZ/pizp88ANEW
         78or6MP82B4I76gHuoyIzO9K44jgc0DLKVY2R5UghYVV04nE9SHFy3Q6iJgLMMDknY17
         YXcMO3NaQQpGW2m3iXu7B6LBxJFP29qT006EBqA/Zl9LuvmSUyQ05hXEwabHFIOf25Lx
         b3f0IdiWs3aKfAIKf/dKbrxzr820Vvo2DrbaQa+CXHIeQ7RCwU8hZZIPhHr6atHLclgH
         aEO3XlEvQ35xiYeXG0AFY3pfFcze7XYVmZ8m1bYtirSihZ965SU3jsYiGf2WeQ2n4ROb
         PLNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWnJyvQU7VSmctqejtLyVSAO7VGkxdL1TJSsZ57tO8HugzFFeet
	AspO3DghCsMEbpxdhX2H+C7Ucwsj5siLG5MbfngASOuijWnM8uz3IRyP1xtExg5TEsx1gVwij6/
	8ML9mg5EktWngkWsxavduFvFgZetgZtXNZXKXNk9/QbSWG1h+WIW5dgxFNbEdg5NyjQ==
X-Received: by 2002:ae9:dec2:: with SMTP id s185mr28810672qkf.107.1552420727214;
        Tue, 12 Mar 2019 12:58:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKYzEJQEoXZNtorzLRYru1BzZhM/t508U36qPDNAoesISXLRzYUyHRHkpVEcQFd1X/NIMY
X-Received: by 2002:ae9:dec2:: with SMTP id s185mr28810638qkf.107.1552420726533;
        Tue, 12 Mar 2019 12:58:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552420726; cv=none;
        d=google.com; s=arc-20160816;
        b=fJMYtlOu9GKapqsv/WukJeLLDF7EPCVLoZI3sEBzH0cRk1rmt4pqNwjFdcwownNIso
         vtjJSGnuFiYD85m8tsjtNCDxS2oQwk8cHVCZ4Pk9mR5CTk7rDLw1EBGw3gfwcc0KWmno
         86UREeRP5FhyaGiJgNFL1fyki+9gtBSZh1Q9Masj1iwmbAP6dlGpNSVgvHc2Wp9ZKjHb
         Le25WIT22u/IoqgGyToJH6kd6CKGz4hFg4sYqpnsRst7rJLC26URujWmQnp2E0zek5eS
         WsNFk8vcF65llv1reb/4Wa7XvF0YsdSuiFQ0iibVQAIySPQJ/J7BzLfGabH7YcUyDVeQ
         J7rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=T3dIU6k3ikBdNxmUckxy77ienly2WxhsLcwRGC+ABT4=;
        b=clAfvAflhiMhYZoijk8rM9zgwIwI0j+FSalbLvtFu+yFLFIKESfeKCfPcoutTIK13y
         nUvaTizGc4Zj/1Hj7AFoLO+MvdqC2zP5WB90fAYyIjt03//jeg/ObZfgwVdMrfc5YLyo
         Fdsyvp0k8U3WFggAJnLXmPQ9T7a7jxJdIMpxeLwSpjRVQ45IftJopovpZA8nVFrjaNSc
         grVF5TvygO5k/RE5EkNRj6w5jmhEnVnRiUVZAbMHV21mUQvnXFRLGRt9MdXSSO4pBTzw
         roXadAPh8j4V8iwMppoIIp1g/q+GMajnqiXohw0FNHNP5Zq3LcRqWm8HrftEG1hNm0bz
         BIag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h39si2126445qth.201.2019.03.12.12.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 12:58:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 99623883AC;
	Tue, 12 Mar 2019 19:58:45 +0000 (UTC)
Received: from [10.36.116.121] (ovpn-116-121.ams2.redhat.com [10.36.116.121])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CE17719C4F;
	Tue, 12 Mar 2019 19:58:36 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: "Michael S. Tsirkin" <mst@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <20190307134455-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <2b4c800a-0f62-1016-5930-797552c63281@redhat.com>
Date: Tue, 12 Mar 2019 20:58:36 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190307134455-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 12 Mar 2019 19:58:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.03.19 19:46, Michael S. Tsirkin wrote:
> On Wed, Mar 06, 2019 at 10:00:05AM -0800, Alexander Duyck wrote:
>> I have been thinking about this. Instead of stealing the page couldn't
>> you simply flag it that there is a hint in progress and simply wait in
>> arch_alloc_page until the hint has been processed? The problem is in
>> stealing pages you are going to introduce false OOM issues when the
>> memory isn't available because it is being hinted on.
> 
> Can we not give them back in an OOM notifier?
> 

In the OOM notifier we might simply return "pages made available" as
long as some pages are currently being hinted. We can use an atomic_t to
track the number of requests that are sill being processed by the
hypervisor.

The larger the page granularity we have, the less likely the issue in
running into this. But yes, it might happen if the starts align.

-- 

Thanks,

David / dhildenb

