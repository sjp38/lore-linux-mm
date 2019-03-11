Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94F64C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:43:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AD9E207E0
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:43:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="czcE+fvE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AD9E207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3DCC8E0003; Sun, 10 Mar 2019 21:43:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEDCA8E0002; Sun, 10 Mar 2019 21:43:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B58A8E0003; Sun, 10 Mar 2019 21:43:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68C9E8E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 21:43:34 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id x133so1706197oia.3
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 18:43:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=2isQUfJScLSDLlvEohkB04IWO7NJ5LdjUPF+fbxngGw=;
        b=fAi1pX5Bw0ShkWqFVVkDOgNqQbtMKstmW6GnQueENuy99yZzB66X/hFIwVSR5oeOZN
         zegufXXr/Xe62HUqCcy+5DImcb2y7AGopT0ObdDPr6r3vRIcvMSbh2ujFqy/M4JLvnqB
         QNsJ5XGlNGxZ4Esnmmxncu3JrjSUSFbO1JG4pJxEtV9/RXX1yOawRSnzTHL7AqRAZRoa
         I8u5esTRF5hvVpkICRoqq8wbGW+8XYDJjfwai0Z2Ss4GvuGwGAEvFUNenjuAbGwCTH0U
         exCFv/c3EdOIuhyIeNoQ/vgnRJFj5ANIur0k8DG6A9ssF3Cwdclf2DcRDapTb4/MtU6u
         /1og==
X-Gm-Message-State: APjAAAUqVviuQWDcBBkrgGtVLMppHTTxC6Zd62LRdrmCre0Mp9e4QjAA
	NqlTe48gn4ozTisl0rn0XMEzfXqrf9X7TlC7pZ7u2jT0VItFmFawuWjtX7KO0RVYHS0rv/7P0MO
	sdIsLTQ5jSGz4gEc0746Z6ruZdwl4ve5VgZhhyCid0+oGgO5yKlvjD/ey5yvSLRKEX1SR4NKALH
	LTNH4n7O1WNrd599uNanun9pR4aJXGzD2zvqEE+T3uoV3yAkyAx6Kcc7ANFtEdJucoTdh4DsuRa
	etEmmzPIxk3OpgQa4uLp+xz/i0apAcerqYgGGx3jj85M13OAcUtkJygk4G9q3QuE+fE3eeGXhcB
	BSx7Cs0+8dcVz+YJsGjJXuz5dOGiGU4UfGVfgj7YHyvD2orcfBAnFpALvb5wmg1MRY0PpsR3N+Y
	R
X-Received: by 2002:aca:bdd5:: with SMTP id n204mr15518893oif.14.1552268613959;
        Sun, 10 Mar 2019 18:43:33 -0700 (PDT)
X-Received: by 2002:aca:bdd5:: with SMTP id n204mr15518884oif.14.1552268613173;
        Sun, 10 Mar 2019 18:43:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552268613; cv=none;
        d=google.com; s=arc-20160816;
        b=mAce1blAlNLBU2JFrWjd5TMxPEEKlSK7AWApLCrNBjPJCxhKnlRmlE6GS9rKiy+/ym
         G2T+PFbAVW2x5yIAwHRJo2VAu0NRjsN4QNc7Tw7jlFU4i+oTJ2eMdOxwrd1Rc1i0cE2q
         57g39kKByDMVlIjnIsXNI51tEVae+ajID4lbHEpaRmJEPtaTnyhC9lEN7sX5ZZo4LjRL
         6vsIoy7ANJJZKgzSOeIEtCfrvPVGqsSCe/9BP8sEFndV97BqdmQ9XCJjunfzmqcQShYV
         PyRUb3vWzj13iMtaLqbNi80uJuOxNc+rnlK5sSqMoUn6mUPWI3HdXZlUzhVFtNXDgs0l
         9Dgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=2isQUfJScLSDLlvEohkB04IWO7NJ5LdjUPF+fbxngGw=;
        b=mxRJ2tEIeujQ6kciTsdJ0Oy+2dcHVZ4CK5WJOX0TLhHCF2PkVOim4II+gXOvFeNyca
         F9z2EZt+RYIUnHgGP1hbvHhDQgRaiEs9jcNll0c50dvXViskfYR/O3xYXS9zNdc4Ooq6
         zGkRm7bV8rvTvvX9pB/+pyh4VA5ZMCYpQ2uS1+87aXutC4VvYuQyl3DgoDg1RxqyAONZ
         zVPBDqc49LDW1n0P30PSJ8bd6WLfoPGEubYqtXrgyxDOFMcRCBI0v0yOtzqn65ukq6tL
         2pd8zJwrevbKzKaJ4UaMomsvtO07UvWSuGlzLo/7xWzHAB61qqEbJGIYsjLxc4VpXJEO
         wFwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=czcE+fvE;
       spf=pass (google.com: domain of xuejiufei@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=xuejiufei@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b3sor2259524otk.106.2019.03.10.18.43.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Mar 2019 18:43:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of xuejiufei@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=czcE+fvE;
       spf=pass (google.com: domain of xuejiufei@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=xuejiufei@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=2isQUfJScLSDLlvEohkB04IWO7NJ5LdjUPF+fbxngGw=;
        b=czcE+fvEsKdjaBi03GxwrSYOknRSmzVlUk7qGkV1cBpBOuKpQUy/IhpnNJ9VhT9LMP
         7Fe+IPi7km2JpH2fBMjuF9h83Wi6AYkT98M4p/PNTLzqNXJ8vCWK4flni2R4Kf8LyjLq
         OzIBrrf10RuDKkPzreYSnjtSQCni3QqoKjpiQlVTvlS8p0hD+nj+Vpl+kt9gI0RDqVIS
         lFeFD3lyrECS1Ir7+COT85tkVHhI4OpMGXs3irLVvTaSpe68p2xyspA4mBy72nzGI5/+
         etEBvbk+ZAHcDqFc8OoM6tns0WXKgWUhw+yCbn53vTNenHpUfvlhfFLcr3PbXKwwsTwe
         sXow==
X-Google-Smtp-Source: APXvYqxn99mvr1eT3+2/e5vo7wh0bRMTfieRh48HvLtIRas7HGUljayhRiKuCAIE0afEq0H4fShqZw==
X-Received: by 2002:a9d:3b23:: with SMTP id z32mr20003697otb.138.1552268612686;
        Sun, 10 Mar 2019 18:43:32 -0700 (PDT)
Received: from ali-186590e05fa3.local ([205.204.117.14])
        by smtp.gmail.com with ESMTPSA id d11sm1810377otp.18.2019.03.10.18.43.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 18:43:31 -0700 (PDT)
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Aaron Lu <aaron.lu@linux.alibaba.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Yang Shi <shy828301@gmail.com>, Jiufei Xue <jiufei.xue@linux.alibaba.com>,
 Linux MM <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com,
 Linus Torvalds <torvalds@linux-foundation.org>
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
 <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
 <201901300042.x0U0g6EH085874@www262.sakura.ne.jp>
 <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
 <20190307144329.GA124730@h07e11201.sqa.eu95>
 <647c164c-6726-13d8-bffc-be366fba0004@virtuozzo.com>
 <20190307152446.GA37687@h07e11201.sqa.eu95>
 <afce7abf-dbc3-3b3e-9b61-a8de96fcaa2d@virtuozzo.com>
 <cb0e29fb-76c7-ff8a-abe0-9e5ecd089798@linux.alibaba.com>
From: Jiufei Xue <xuejiufei@gmail.com>
Message-ID: <e707b119-2640-b638-01eb-5450d7c3c8a3@gmail.com>
Date: Mon, 11 Mar 2019 09:43:25 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <cb0e29fb-76c7-ff8a-abe0-9e5ecd089798@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,
>> It was discussed before. You're not the first one suggesting something like this.
>> There is the comment near in_atomic() explaining  well why and when your patch won't work.
> Thanks for the info.
>
>> The easiest way of making vfree() to be safe in atomic contexts is this patch:
>> http://lkml.kernel.org/r/20170330102719.13119-1-aryabinin@virtuozzo.com
>>
>> But the final decision at that time was to fix caller so the call vfree from sleepable context instead:
>>  http://lkml.kernel.org/r/20170330152229.f2108e718114ed77acae7405@linux-foundation.org
> OK, if that is the final decision, then I think Jiufei's patch that
> moves kvfree() out of the locked region is the right thing to do for
> this issue here.
>
Is that the final decision we have made? Could you please look into
my patch again and give the decision?


Thanks,

Jiufei

