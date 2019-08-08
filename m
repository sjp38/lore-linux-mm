Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD135C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:10:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A638F2184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:10:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A638F2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=redhazel.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 404A76B0007; Thu,  8 Aug 2019 11:10:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B3F26B0008; Thu,  8 Aug 2019 11:10:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CAB46B000A; Thu,  8 Aug 2019 11:10:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D503F6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:10:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k37so1685662eda.7
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:10:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :user-agent:in-reply-to:references:mime-version
         :content-transfer-encoding:subject:to:cc:from:message-id;
        bh=ifo/pJmfD7qppS0boNqOksAUn5OSD5K48ZxQ+tkc0CM=;
        b=Fs4zqFdfhBaZ0e50Vk3u/DM0IvsgaFEsjtd1IfxAOPUdG74dZ5Z7uwKlB0zCOpxDFE
         eGBhuXztEEkMFP8UgaD6HkVywMwv3y2QbvuIUyFE102HQZt5MD8jpjV3e6kP6hmVF/a2
         7Ic7lmBE9v91A2RMuu2rMEUChqMcHKZj43MjCsix+EPwvMmnd9hWc2tmj+fvsuwt/0MW
         NxV9kXFHi0Y7DQVySOSv1vfR7TK6jfrkI4SoD/crjWv1Q7MAWxQvHExB7npIvsha9WDF
         Q+jCJrw21Z8tET3QqgEyojoZPXQ6PUoGRcUy6vupY3gdtA1sVl52KVn+PAnGjmJHzqab
         C3GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
X-Gm-Message-State: APjAAAWPF2s2VqW5hJDsKlREZ9AQLtv0YuNnrFQ1CvOJttY53QAFk84x
	lnOeAi7DB3Wku7FlwBeERCsHOO1YqZ6CnpKDTK2hb5yNJcMBKEM6LYDH6boHxkThxcnUZ3ikOFv
	coLtSswzRLf5oOqcH0s9clqpqzr0o8rV/fJ6CY7FBwsml67rJq6NAz3NY0uwebkUQkg==
X-Received: by 2002:a50:aa14:: with SMTP id o20mr16527670edc.165.1565277010446;
        Thu, 08 Aug 2019 08:10:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzg6MKUFvBNAqzUdEdu76NVP6zUmth7UYGX1DblRo2Br1lVt6cKFoZZ1tGVfqoKUcyieACI
X-Received: by 2002:a50:aa14:: with SMTP id o20mr16527600edc.165.1565277009765;
        Thu, 08 Aug 2019 08:10:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565277009; cv=none;
        d=google.com; s=arc-20160816;
        b=jhkUD4cTENPbQCLIjwB0/jMKltvnWiUQAVAhKn1qQAJYwDS72kJxU/x6uoiqal7Cxd
         QyxPOil5g2nJAqtvliZI24pJwtN/WGIbu4kyeTGDexeSNtCJ2A0fvAKXZ1Koz7Bm2luS
         8DWogFgQtTn63GPp9mvyhWapcJcbkIn7Jpxj7qvrDdIVoXYqPcemVIInPzRhcEYaXIqA
         IaHG3NLeko5sLHCMCFhEewx9Fp6UyxdyVdH1zlOv391B5ouqpE6DTfxV6hNC7bziX7sP
         /au6Axp6GmxZFvdAqhYzapB6/LHzWe5YEAlRxj7MIusWK+RnI7TOXwX/RhkQ26VpPx5e
         RNHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:from:cc:to:subject:content-transfer-encoding
         :mime-version:references:in-reply-to:user-agent:date;
        bh=ifo/pJmfD7qppS0boNqOksAUn5OSD5K48ZxQ+tkc0CM=;
        b=YQRDbk5k6M8CMphwpy6Aa5Bdl9+ITMl+FhK405aUlfPGSuNXcVOR1v82wHS22+hlHU
         E5XpTYjL7LegSpU7MihoZxWE5vfhoqAU032+TeJtymLSw4Zg95swf3cK3YMmETeEJHeW
         OOT/2Cr+8sx/fk3dtYPGjNxmgca8keAK9MiiMqbMSS6kIR+RcYadwZg/Z5ra44ygs1Js
         0tukVGtaXaXD3cOy8BNqBa5ScV+FtzG90YL89aNpEomO17GK6FWXxfV0OYRWZ+SNsnVE
         +maDVlgoT7w0nN7LJceqedP40PsOGL6XCRTm6krR4hiDQwW+rxKc+PngsV0HJRf4Utos
         aMug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from vps.redhazel.co.uk ([68.66.241.172])
        by mx.google.com with ESMTPS id h26si30977372ejx.394.2019.08.08.08.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 08:10:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) client-ip=68.66.241.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from [100.121.56.177] (unknown [213.205.240.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by vps.redhazel.co.uk (Postfix) with ESMTPSA id 1A2EB1C02183;
	Thu,  8 Aug 2019 16:10:09 +0100 (BST)
Date: Thu, 08 Aug 2019 16:10:07 +0100
User-Agent: K-9 Mail for Android
In-Reply-To: <20190808114826.GC18351@dhcp22.suse.cz>
References: <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz> <20190805193148.GB4128@cmpxchg.org> <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com> <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz> <20190806142728.GA12107@cmpxchg.org> <20190806143608.GE11812@dhcp22.suse.cz> <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com> <20190806220150.GA22516@cmpxchg.org> <20190807075927.GO11812@dhcp22.suse.cz> <20190807205138.GA24222@cmpxchg.org> <20190808114826.GC18351@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's inability to gracefully handle low memory pressure
To: Michal Hocko <mhocko@kernel.org>,Johannes Weiner <hannes@cmpxchg.org>
CC: Suren Baghdasaryan <surenb@google.com>,Vlastimil Babka <vbabka@suse.cz>,"Artem S. Tashkinov" <aros@gmx.com>,Andrew Morton <akpm@linux-foundation.org>,LKML <linux-kernel@vger.kernel.org>,linux-mm <linux-mm@kvack.org>
From: ndrw.xf@redhazel.co.uk
Message-ID: <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8 August 2019 12:48:26 BST, Michal Hocko <mhocko@kernel=2Eorg> wrote:
>>=20
>> Per default, the OOM killer will engage after 15 seconds of at least
>> 80% memory pressure=2E These values are tunable via sysctls
>> vm=2Ethrashing_oom_period and vm=2Ethrashing_oom_level=2E
>
>As I've said earlier I would be somehow more comfortable with a kernel
>command line/module parameter based tuning because it is less of a
>stable API and potential future stall detector might be completely
>independent on PSI and the current metric exported=2E But I can live with
>that because a period and level sounds quite generic=2E

Would it be possible to reserve a fixed (configurable) amount of RAM for c=
aches, and trigger OOM killer earlier, before most UI code is evicted from =
memory? In my use case, I am happy sacrificing e=2Eg=2E 0=2E5GB and kill ru=
naway tasks _before_ the system freezes=2E Potentially OOM killer would als=
o work better in such conditions=2E I almost never work at close to full me=
mory capacity, it's always a single task that goes wrong and brings the sys=
tem down=2E

The problem with PSI sensing is that it works after the fact (after the fr=
eeze has already occurred)=2E It is not very different from issuing SysRq-f=
 manually on a frozen system, although it would still be a handy feature fo=
r batched tasks and remote access=2E=20

Best regards,=20
ndrw


