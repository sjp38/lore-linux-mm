Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84B2EC19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 17:12:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E81D206C1
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 17:12:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E81D206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C985F6B0003; Sun,  4 Aug 2019 13:12:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C49226B0005; Sun,  4 Aug 2019 13:12:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B11FA6B0006; Sun,  4 Aug 2019 13:12:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 641C96B0003
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 13:12:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b3so49922239edd.22
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 10:12:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=cGEUCcnx89mro+XuO/BqzAP20YUw7IHcS3QxblXKIVg=;
        b=b+plQJG+gwWmy4iEI1g2VWjxgptKbwjKRsxCHKepY7bSW13Ykp2IsV94XpN8oW3DR5
         YdpvqCRodyr+FiX0C//YTqiRbaMu1udst0QDlZ83Ktnx3DUmYw0XOwpNXxQRyUvwpcHp
         8JnBrozfaxwKdEoqtYYtDvBD1LirecNS05t1vftYSUpSbI6xaIaqLeQ7Xc890fOm0BzI
         AiP9FVgEtemsQLRMeqOqzrcIhLvUqNCyQEAms8IE6vrk79XUVaHWQ1epVArNHm4kONxo
         P1cIjqWgf6YJMaJDgXv1sHJXejtjB33XFcvQlEml567HcWbq1Ak8bvIixoKzejsZw+X0
         roXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nborisov@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=nborisov@suse.com
X-Gm-Message-State: APjAAAW9fSpgDmClrLkE/KkDI40YvOpixe7Gb1Dlery94iBz0oAqZPVF
	agRQ23R86Uj6IrG6dvLKHwXOm/AQRe64mHSjH55x6BZK1INGwOK8A2pHQqhCpzw81JjEjynAeqd
	JfOY2Fb/a+6Z1SvgmYNGZ/jfgOd+hzKjc1S60bZn94zA2GsbfRwwLNr7ynht0FArhKw==
X-Received: by 2002:a17:906:802:: with SMTP id e2mr113359403ejd.59.1564938768974;
        Sun, 04 Aug 2019 10:12:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzR06bEtkeYf6FntHKPi8fYW+TpqJjs8l1Y0Bu8lzon0tHNKfUQj5uxDJBeCJQb/5LBsrdU
X-Received: by 2002:a17:906:802:: with SMTP id e2mr113359358ejd.59.1564938768111;
        Sun, 04 Aug 2019 10:12:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564938768; cv=none;
        d=google.com; s=arc-20160816;
        b=v/UmEyx/u8GJynKICB70zP88kxBw+eriIBXmlvAJTdRUGNLnsfL5nDJPWUdZ0cu9ca
         ekB5gdj7oNWiPY3oDZ2FBYCoStUEXfekQcNsDjpxfEck3qCnYi4DLLfGQJy/Jj/g1Bm8
         bFSsTBd1cvKuqS0pZp97887G4sNLegUiJvBGosIJhH8eUhSYwOky8RenoOjfSZoB2Y8J
         pY7/uQXuD/d1ozUpoYFMcbicJ6kKRXPykivBzut7P/6axm+JMbwR954dMlQbZzor5Px3
         V82eKN7Cgl3Mnz0yaSKnUof/oGvz0hY93eN7B50W6NStqrNtubvsD8W/wLw0Vo34Iicq
         VphQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=cGEUCcnx89mro+XuO/BqzAP20YUw7IHcS3QxblXKIVg=;
        b=OSKXgB4nwXBPrqMlyRjntXZyIuCqG2EdSYeo2lMk09xhOV/vK7z56azHp1O4dxKm8n
         5sH9tjA5a67fn3kCD4lwf15HfcA+/NtcKu7jbd+IIkwlLTj8f4zvaORVTJsQYScxZTvS
         V6whnESjfkioDZn1GPG9FGf1VGwd8cJins2nx3x0NNczwsih+ydZMtx84lk9qaScMccy
         z6x5CxJJ4Y1nWn+tqUhVihXVG10GytHATTS4rDI7ViX3LthaTK+xLlPLAiyiFnqZTlR2
         yQicB+HFnfIENoAX7ltzaK+vheGG/2zDhniKd8FR29sqvigUdt2dTKjWbAhF9+xMK96s
         jNig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nborisov@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=nborisov@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f35si28445024edd.350.2019.08.04.10.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 10:12:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of nborisov@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nborisov@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=nborisov@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0B258AC8F;
	Sun,  4 Aug 2019 17:12:47 +0000 (UTC)
Subject: Re: [PATCH 16/24] xfs: Lower CIL flush limit for large logs
To: Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-17-david@fromorbit.com>
From: Nikolay Borisov <nborisov@suse.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nborisov@suse.com; prefer-encrypt=mutual; keydata=
 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
Message-ID: <b8b711fc-ba44-b510-91e8-8b6c247c30f3@suse.com>
Date: Sun, 4 Aug 2019 20:12:45 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190801021752.4986-17-david@fromorbit.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 1.08.19 г. 5:17 ч., Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> The current CIL size aggregation limit is 1/8th the log size. This
> means for large logs we might be aggregating at least 250MB of dirty objects
> in memory before the CIL is flushed to the journal. With CIL shadow
> buffers sitting around, this means the CIL is often consuming >500MB
> of temporary memory that is all allocated under GFP_NOFS conditions.
> 
> FLushing the CIL can take some time to do if there is other IO
> ongoing, and can introduce substantial log force latency by itself.
> It also pins the memory until the objects are in the AIL and can be
> written back and reclaimed by shrinkers. Hence this threshold also
> tends to determine the minimum amount of memory XFS can operate in
> under heavy modification without triggering the OOM killer.
> 
> Modify the CIL space limit to prevent such huge amounts of pinned
> metadata from aggregating. We can 2MB of log IO in flight at once,
There is a word missing between 'can' and '2MB'
> so limit aggregation to 8x this size (arbitrary). This has some
> impact on performance (5-10% decrease on 16-way fsmark) and
> increases the amount of log traffic (~50% on same workload) but it
> is necessary to prevent rampant OOM killing under iworkloads that
> modify large amounts of metadata under heavy memory pressure.
> 
> This was found via trace analysis or AIL behaviour. e.g. insertion
s/or/of/

> from a single CIL flush:

<snip>

