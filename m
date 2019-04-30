Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82E6AC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:54:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CDB520652
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:54:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CDB520652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB53E6B026B; Tue, 30 Apr 2019 05:54:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C65F86B026C; Tue, 30 Apr 2019 05:54:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2D5E6B026D; Tue, 30 Apr 2019 05:54:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B12D6B026B
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:54:01 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id e2so67431lja.16
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 02:54:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uVlf09ii/gJaQyHiqAtHym+8xBl8rU9MIovaRXcsJS0=;
        b=RoZ4pG77xUIHow3I7oIIh2ryRRod5klNRdbYMz71NqCVMLAyAJxik946QYJhg9S1ih
         iYVcTz7KimFpVkfmtO9qpyJC2fwnpIoWxHI0efREK56WiNidxxH6pN4Lh5jMbEOQUmdf
         3ioRS2vEIQXnYd5tBHswukTMXEFbiDw2bxWP7t6SE2/n0GXOdpLm2WQB7Pvm86ElhpBt
         RYOhQcfzLjr55GKxa7osazUJ1Eg6JkuqK582OTCjcsha7mZxvFGmUr+NI6SgwcziI6tx
         5SwNoKSibS1ujRewJSoSP6Y3eo/3mjOHZpy7AYOIm0ICdZbADoiNrSTGKvLGTvU0FOnp
         pFag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWyl2Ac+NCtMXv+k/Tz6Zelq9uIdnRErq3KLETLN4OXu14yVbQO
	WAU25HSqLUIMtDovaRoAAwsS6Uaabh8OEpGfgDj7906hB+fGLKjkdZknO2IUtUCXdsFrwx7f7mQ
	dxvYkIW0xeFLg6KO7f9WUbXREGVyIwY19QuT7bOrKFinujnSmE/hCBvB44XS6KiyaYQ==
X-Received: by 2002:a2e:9956:: with SMTP id r22mr1757866ljj.143.1556618040699;
        Tue, 30 Apr 2019 02:54:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOhnhPm76gXNnK1iF6PgZPyKJPCtZNM/7cHFe+htRKG7JIUuVI2f5lKpUVIH+ao17m1arV
X-Received: by 2002:a2e:9956:: with SMTP id r22mr1757834ljj.143.1556618039979;
        Tue, 30 Apr 2019 02:53:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556618039; cv=none;
        d=google.com; s=arc-20160816;
        b=SGgjGP6A14CtDgC20LquyvjLJEg11mp3q2fMFi8eI7VGUN76NhraA+VFJS9eREzK+8
         ai0+rzXt8L6hgOvz3/PC4opYGhkXTFddz0jEt+/z4EhlXDO2VGq3P2Gdn02u4tqtJCrW
         1nuSgEVxcd+NRvgi9SaWJubVA63Qbvc918+rjalgp4n7/u9dhffCV9Sx09oEUwzZsT0X
         buktSWW/palMBAQTQ/FeG5cToIzTJkBnRvU132xdWXWqmkKdvtRtZdnN2c+2/Bbybbmf
         d8RBjxtFYGDDQgeBr5mVDW7eMllAnO8OFET/D1pJvFA2GoxxHWw/+blfdpkoUCGsDLEH
         uO1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uVlf09ii/gJaQyHiqAtHym+8xBl8rU9MIovaRXcsJS0=;
        b=H/A2Q25aljIgeoY41aF5wXq6r16h9ziZqANQ1yjreergrGUqVKdUWkY9d93gsXcRxC
         EnCXTR8f6MARHNYDQaKUDNMLpuixaRJT8v/0CxIxkgkE1fWsJd3VtKoKGlaCjeA+51PV
         aHwoGR+0QNHGu5JrivmNwXrF+hS/3+lmo/JAiGFsWmJvRQWuFy75CINkLScTxb2kWGLE
         KVtTtE9eQ5yejm0M3+Z5RiHw+TA74vg1e0kBLg2RzDIfg60aWP7lotaYCX/pV4AYatId
         tjB6uZZLpeQIWzcXpDIxFe7Ae5NQhFHXMQTL6qRD8rjcsv1PB7Y/4Tn8ECzae+jo0lQC
         3FaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id b22si28392468lji.74.2019.04.30.02.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 02:53:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hLPSS-0007ia-U6; Tue, 30 Apr 2019 12:53:53 +0300
Subject: Re: [PATCH 1/3] mm: get_cmdline use arg_lock instead of mmap_sem
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
 akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
 geert+renesas@glider.be, ldufour@linux.ibm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
 mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-2-mkoutny@suse.com>
 <4c79fb09-c310-4426-68f7-8b268100359a@virtuozzo.com>
 <20190430093808.GD2673@uranus.lan>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <1a7265fa-610b-1f2a-e55f-b3a307a39bf2@virtuozzo.com>
Date: Tue, 30 Apr 2019 12:53:51 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190430093808.GD2673@uranus.lan>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.04.2019 12:38, Cyrill Gorcunov wrote:
> On Tue, Apr 30, 2019 at 12:09:57PM +0300, Kirill Tkhai wrote:
>>
>> This looks OK for me.
>>
>> But speaking about existing code it's a secret for me, why we ignore arg_lock
>> in binfmt code, e.g. in load_elf_binary().
> 
> Well, strictly speaking we probably should but you know setup of
> the @arg_start by kernel's elf loader doesn't cause any side
> effects as far as I can tell (its been working this lockless
> way for years, mmap_sem is taken later in the loader code).
> Though for consistency sake we probably should set it up
> under the spinlock.

Ok, so elf loader doesn't change these parameters. Thanks for the explanation.

