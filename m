Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8C5BC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:48:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A98F82084F
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:48:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="xS6pYk6l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A98F82084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2911C6B0008; Wed, 15 May 2019 04:48:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 219EB6B000A; Wed, 15 May 2019 04:48:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 094746B000C; Wed, 15 May 2019 04:48:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 95B7C6B0008
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:48:35 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id m26so433116lfp.18
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:48:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RBKOGGXjvQMTQzfr1KxZ/9oyUSl618uUSUuLqd4U4J4=;
        b=qJniLxVE3U8jgcoYZZRZiF/P5xiquwi2Zc1Z4ci5qkj4sb/txdo2+gKgp4BGv8C2iz
         Ag8acDy1N3z5cwsktgS5woM1diolpa1bNfPH/Y7YhJZP6cLNLUgOxKbJLukSWHPvesoZ
         K028p96HRCdubFiwzc23Xt6aU5zLfgxV6b7eqUgRtQsPDG62qTrXt0rM6q5RZLjoacy9
         1UFVHQEkvcPw6GywimaLUaHLTUpOWkzgQDajlMeg3AEbX3oVdaOVyGn9Xw4GaTylxaCj
         NUM8Vb+ep5FpNLvMKZal0GK+6VDi1qvcaQvn+RuPxczDNHFWg0mk71rIPMS3w97Uh4mW
         XZwg==
X-Gm-Message-State: APjAAAWC+2JlrQFcYd12dfJqkWGVbqAp4NzZIcrAj6FwpGRQwSaB+TKF
	oMlqyfJJYLHlA4TYwngLsDIwjSwEaRuW5tRIkYzdO3AsprdbXkK/OqA4Z0qJ7RtlCkfuEQqCh+i
	d/5tWfF++5B/0YQS38zN+iGM3dui8q06HLNKtIVFinC1nrSYBhojv/6xY2u9fLNMNPA==
X-Received: by 2002:ac2:41d7:: with SMTP id d23mr8889861lfi.118.1557910114955;
        Wed, 15 May 2019 01:48:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMvjmY/GMkQRuto3Hs0PUOl7yuY5FD9iEVZtpmetvIpKnWsmio3GyP4go8whgLOJdArswC
X-Received: by 2002:ac2:41d7:: with SMTP id d23mr8889831lfi.118.1557910114219;
        Wed, 15 May 2019 01:48:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557910114; cv=none;
        d=google.com; s=arc-20160816;
        b=SXRqNnbMO7+NwpgvKZ6j3EYErfOD5IO0hOYrgqia+cS9fubp1ONDcLEstLL40eLL95
         3TwynYVpOLtyHIQgwM8UhBGiWiVJs4vB798hpajuTtntHfOeKN4V5Ugwg9G53yRKIW01
         9zboNCi6aBp3W+p+vgimTBEJNd1P2rOxzgyXtbj/KEmU9CJstunjwhL8F9wkJij6bQfd
         c/HqgSNjYnxs1zTGVlfEaFH2JBvgVH7uIY+ErwZcQmgjMu1AcNcQOVrmLFisAW3hSc60
         v99CGLmdP5YwmpLSkbU7nz2FewTxfg5ivasHEjooQPXalM6P8ZyhbvppyJym10j1Y2vP
         GO0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=RBKOGGXjvQMTQzfr1KxZ/9oyUSl618uUSUuLqd4U4J4=;
        b=bsZ8lVr2GEhpCbaknwpwj0a+oQ8l8htsVO42+IbcNmVZ9jWmmUfB2ifSQbiZtqrb/N
         FxbuWyFPJ16r7wbHx2x+q7txxFr/t1MF0m8Pq/juonCf2rc2+BlI05APWyhQAmwcoJg8
         0Xi+sAWNeMH+NG9qFQkYgCkWE0+barMQ7et27YwHLK3NRCp/TffTXD6FMtjs12Ho/UpL
         v3ybedtoGq8TJFiKkJD0PLRka9Z6byW3vRGzXbR0sBDuydJa4UwUKcW04JRvPnHPCA1u
         H7hlm2X8CD0W+5mzmNEKC/Zz3wOF6hoKgXNptoPTv2ZFpp685c9czElsOYOIzTt7WrRI
         FqFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=xS6pYk6l;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [77.88.29.217])
        by mx.google.com with ESMTP id l22si1119619lfh.36.2019.05.15.01.48.34
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 01:48:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) client-ip=77.88.29.217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=xS6pYk6l;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id E97EF2E146D;
	Wed, 15 May 2019 11:48:33 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id Q7pQ1sTs55-mXwKadUT;
	Wed, 15 May 2019 11:48:33 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557910113; bh=RBKOGGXjvQMTQzfr1KxZ/9oyUSl618uUSUuLqd4U4J4=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=xS6pYk6lclpU7VNMA86o90Cjw5stbFWI+4tB+0YsgkUrheiouBQ8AFz8MpyH3KX6B
	 cYl8QrQFZIGVKhNgLsQ5GI7hC5vZalPybRoqEZphXJ6kxTMy+pJlDcuospumbfhH/6
	 AX9OFu7taypLf891OGXJ8oBpDBEjmuIz6A49Iw8Q=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id F0Vfe9DM2Y-mXlCWMAt;
	Wed, 15 May 2019 11:48:33 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: mm: use down_read_killable for locking mmap_sem in
 access_remote_vm
To: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, oleg@redhat.com
References: <20190515083825.GJ13687@blackbody.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <11ee83c8-5f0f-0950-a588-037bdcf9084e@yandex-team.ru>
Date: Wed, 15 May 2019 11:48:32 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190515083825.GJ13687@blackbody.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 15.05.2019 11:38, Michal Koutný wrote:
> Hi,
> making this holder of mmap_sem killable was for the reasons of /proc/...
> diagnostics was an idea I was pondeering too. However, I think the
> approach of pretending we read 0 bytes is not correct. The API would IMO
> need to be extended to allow pass a result such as EINTR to the end
> caller.
> Why do you think it's safe to return just 0?

This function ignores any error like reading from unmapped area and
returns only size of successful transfer. It never returned any error codes.

> 
> Michal
> 

