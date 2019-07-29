Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 778E4C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:55:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4666220659
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:55:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4666220659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFB058E0003; Mon, 29 Jul 2019 01:55:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAA4F8E0002; Mon, 29 Jul 2019 01:55:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A99AF8E0003; Mon, 29 Jul 2019 01:55:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2E68E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:55:05 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d9so50953169qko.8
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:55:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=kBh8gEw5sOiFQNt0lcoUZUxyhsE32cFi16v7FMnglt8=;
        b=oviQ6znIptUcq3sgWwqx665KL+52Ca7mXRu4F37PuD614EcfczQKuYp4qjeTNOBNv/
         xOrRRs1Ch18bPcRvk917UZRGx1vTfhh/BYrie6hR0pjAyy7VfR5ZNuzXDkbVYYrleM9Z
         2n5eCddGkqXZOXlRT3kQDJPHeWQYhN2BpooeljnJR/+kWiSsPPx1YvTOeEYmaQvWd1MW
         soHPUCrjlEtCSqfQxMfYYJc0ReJOqsnxNz63j7K5X5rMwIeChigXz/RAATI7434NTHFa
         0vVRxZnsEHzM3OxXHjZ0S851yi9WjpSeLHd0XlFzcbt+y3Ci7C5dUDkzdcu5NOLmeu24
         76Nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX7fjsMasFWHxsuVZ65p/T1267Amz5NG81iokBFeFobOK27NH1U
	qVrwB9JUp3CPMRWWyCVSoBEbnIR/Yp8O5+01ugEEfuu/3flYMZZl9r8+cXug33jteTPhuh6+xt8
	kA85Z1b9qqz5jClkhQVqKj11mNYB79ckzRLIsSLw92VBNpDoXGeoZ5noMjSp5poO1Xg==
X-Received: by 2002:ac8:5297:: with SMTP id s23mr77408055qtn.230.1564379705342;
        Sun, 28 Jul 2019 22:55:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZkdWXxcC9HSvalzSqkntLxp0hyHzQ1dtcBy/FQfxMm2S/xY72vtxgH//KUMMcIOrixluX
X-Received: by 2002:ac8:5297:: with SMTP id s23mr77408036qtn.230.1564379704706;
        Sun, 28 Jul 2019 22:55:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564379704; cv=none;
        d=google.com; s=arc-20160816;
        b=ENAzhg/EeALlbKWhj0an65rybFr1kGFmLZZ25vIcHXOz3YhVJwdBjXa1CxbcVV37up
         RsF8FCite0Kyy0CNsm+EVtAUinPalyuQYBBWopmEP+g1guZgXWRSlyK7P6JYtIuzb2n3
         LTI68KE0psborDcYV0dwS9x/vNF12NAL9P9uhayvl6chxpXc/10ziuO2mM+Aaido99rP
         DMXpNI36LX5V8bbbAm8WYpjPtIrZJ9xo6qLheyrwL4DLAUu7H+czmpYOtxuZgXxAaWzB
         DohJBZV1el3Lwq5a7gfuW2yIe1oJcWU7jV1B2/S+mwpovP5NkHtct8jBauX47FH6aUmA
         xCDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=kBh8gEw5sOiFQNt0lcoUZUxyhsE32cFi16v7FMnglt8=;
        b=AZDRTqZBoZtiJiehs2NOVil6BAUsxXxYbLwM4dYx11ZVkq+WINo4EoKvskzAVtwNLX
         dwYlNywSEkfiJqnGFJA2Rp3jS7h69feFOBB4cy5eTwIzJiyrbysFQyQbwE7YyqbkGsMb
         Z2xI1MrC3iWZYIJNjQqFFXgOAmqierJv7AIcPJtvFlSOcLlt3F6MdJRMdobIrfb4RK2e
         xzwfQbljipKWfUbTYOy6jIm5SZvZ+RT+d+ZMZbAnPSYzwtoWzfn9f2spifE+/D+pPIFH
         LBHeSQ4qwX04GOtAZ0/7GhWQs3SXyUXa0RBsjphUvKkx6LIS6taMRb2QMCCd2/HLA9wM
         dssQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l4si23882436qtb.237.2019.07.28.22.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 22:55:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3B5AF30BD1C0;
	Mon, 29 Jul 2019 05:55:02 +0000 (UTC)
Received: from [10.72.12.53] (ovpn-12-53.pek2.redhat.com [10.72.12.53])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3C5D55D9C3;
	Mon, 29 Jul 2019 05:54:50 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
 davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
 guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
 jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net,
 mhocko@suse.com, mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
 syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, wad@chromium.org
References: <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
 <20190726094756-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
Date: Mon, 29 Jul 2019 13:54:49 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190726094756-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 29 Jul 2019 05:55:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/26 下午9:49, Michael S. Tsirkin wrote:
>>> Ok, let me retry if necessary (but I do remember I end up with deadlocks
>>> last try).
>> Ok, I play a little with this. And it works so far. Will do more testing
>> tomorrow.
>>
>> One reason could be I switch to use get_user_pages_fast() to
>> __get_user_pages_fast() which doesn't need mmap_sem.
>>
>> Thanks
> OK that sounds good. If we also set a flag to make
> vhost_exceeds_weight exit, then I think it will be all good.


After some experiments, I came up two methods:

1) switch to use vq->mutex, then we must take the vq lock during range 
checking (but I don't see obvious slowdown for 16vcpus + 16queues). 
Setting flags during weight check should work but it still can't address 
the worst case: wait for the page to be swapped in. Is this acceptable?

2) using current RCU but replace synchronize_rcu() with 
vhost_work_flush(). The worst case is the same as 1) but we can check 
range without holding any locks.

Which one did you prefer?

Thanks

