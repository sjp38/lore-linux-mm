Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74BB3C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:33:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31ED920835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:33:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="G+K/q8tG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31ED920835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD98A6B000A; Wed, 17 Apr 2019 15:33:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B874E6B000D; Wed, 17 Apr 2019 15:33:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A50836B000E; Wed, 17 Apr 2019 15:33:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 833DA6B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:33:11 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id y64so21814319qka.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:33:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DOvyhaD8UYdSm2Vgv7oMv8UKm8AtpoXnW18vA0Gu7bI=;
        b=lMK+xaQc5kk2OXPeN3dY6MFUICOkfM7EExAGc6EGbYlGGaPSC5mnw50ZiVfdl1NYMq
         cWund+TgYncFWt1/TGc5lS15CnGddgnEmrgiPEs5ocPQyKev2IAniiCnuM3LFa/AIZGK
         RjI4sz77ZeQEiLeFBEBIgaR5o2UjKtaFpaps5apB0OGcKCyhq3/V1V69SSOZKAtTb+TP
         wwEUvL0DREhlkGgSozQijZ0DF6pwnp++sp7DwwQzVhlBlp94TWu/+nf4wGFk29L079bb
         UvFRd7i3LzvExzvvA4ZerpmbHWfobXRfA2sNX3Pu2Ni3AX4T7VnsN8KmtrRk7MVvAs32
         cn7Q==
X-Gm-Message-State: APjAAAXb3TRiRxVt5UgTSXTpPHc3Q6kJNV939RIheFeuWvcQhB/l+5AS
	gVSp8Q0kDo80B59yUgobej2gLrKJyN1OKSGScHJwR1cs+cUROdj/JLa3KaW9UcrHCVYWhGlGRxM
	xLexY4gYaleUxgxSMnEIs3ZGkUGaTMSQAbtnUGgU187a2r8D+wnemKfBaC8VX/zs=
X-Received: by 2002:ac8:71c3:: with SMTP id i3mr45277629qtp.140.1555529591228;
        Wed, 17 Apr 2019 12:33:11 -0700 (PDT)
X-Received: by 2002:ac8:71c3:: with SMTP id i3mr45277606qtp.140.1555529590692;
        Wed, 17 Apr 2019 12:33:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555529590; cv=none;
        d=google.com; s=arc-20160816;
        b=YnQaq5dFaLJHtwkwKmX3IWTt5ABwh4MnO06/uDoB2Ddb7Z+bQ2g513D8BF0tlPmbj1
         GCEbuiH/ZzLnsnfFW63vdlWH5ZcsacbnCu0NX7lqON3aLIRjaV/A8Sagm/jpu2aIT6h7
         V15gGXJou8JAd0Ik9AQS4UQIiRpM7TvrPqpUB1NbAni9Hzhz67EGLev4zL2DPjRdeELK
         ALujzghNv4zKu/CuKfwzBko6SHE3ZHuF8R4OEmRlBXMhtEXO2a4vI+36o+T4qsAdv9Hr
         hWsTTMYagNg7SlC+6HoafZzS4IjxmK+TJ2IQ4JzQo2XbYVrwaP6aQEbHS7kCNMcJEy8u
         +vgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=DOvyhaD8UYdSm2Vgv7oMv8UKm8AtpoXnW18vA0Gu7bI=;
        b=KGrdbEYIXwJgpbR3DKsxptRzmI47MLNw9hV/9gTM+xvhmBtaEmFWtEgh5iK1phbrSA
         +duZfYW/G2WUxhAJj50W7FPMYLCLW9CFbaNuvnMvM/FWQEHUUS8jGMEn79t4Ew5X8pPn
         TZB8LS7FLlmYmuZ0QMBYdd7zM17eP7bAKQ8da+rWUNqC39fBpvICUanccduAwlhwKRMH
         fI+XlMjx0J2UckpWVxtKJBJsyIfljBt+YapB2hPxC2R9KSPzUIyzOsCPeeoL/bH4IR9v
         Dm973mIAw6U9f5PybgJhalf0MYXx1HW8GLTwN5nF6WLR0+85gJ3TZbY21wHMEflCM7p9
         PFWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="G+K/q8tG";
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d16sor29776615qkj.124.2019.04.17.12.33.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 12:33:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="G+K/q8tG";
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DOvyhaD8UYdSm2Vgv7oMv8UKm8AtpoXnW18vA0Gu7bI=;
        b=G+K/q8tGKTnlv7InetTqxljKuwUd3WFeH/9PINgqo9/wtLSvb5dr8RIY6GMteOYwxg
         keyu/4T1TSgaUHyvaJZVjytRQPhL1Dry26oFQpSJTJYmdEVdSMZH9CBg2EjoNX0rlUJq
         P+MipN8w8DZ6VkHJccSQlegj2WxTZD4zYGmj3rvlT/RgpP/wODPNqWMKODrucK94QARS
         APBP/MvDke+RXWKsSrgJOPpBGkS4R3CUqMyYjuVP6iBNk+ZpF1FsIzrxAkejisfu2h3d
         13D+YkmTv1zidtlGT931ukuwoDbmZ++ypEl1e7oLBXErb1C7B8MDMmb87wiSimgKanP0
         VuYg==
X-Google-Smtp-Source: APXvYqwwsHOijzy5+qi54DMe1CUqg+364Ctp56sTADYW6ZdkvMX3KxBajWgTrNG6hjWJFl3Tu/7Fug==
X-Received: by 2002:a37:5547:: with SMTP id j68mr6182374qkb.199.1555529590306;
        Wed, 17 Apr 2019 12:33:10 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::3:556d])
        by smtp.gmail.com with ESMTPSA id h22sm44750929qth.68.2019.04.17.12.33.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:33:09 -0700 (PDT)
Date: Wed, 17 Apr 2019 12:33:07 -0700
From: Tejun Heo <tj@kernel.org>
To: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
	joseph.qi@linux.alibaba.com
Subject: Re: [PATCH v2] fs/fs-writeback: wait isw_nr_in_flight to be zero
 when umount
Message-ID: <20190417193307.GF374014@devbig004.ftw2.facebook.com>
References: <20190416120902.18616-1-jiufei.xue@linux.alibaba.com>
 <20190416150415.GB374014@devbig004.ftw2.facebook.com>
 <f3b2fbad-fc9e-d10d-9f81-9701bb387888@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f3b2fbad-fc9e-d10d-9f81-9701bb387888@linux.alibaba.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Wed, Apr 17, 2019 at 09:04:48AM +0800, Jiufei Xue wrote:
> Yes, it can be fixed if we replace synchronize_rcu() with rcu_barrier().
> However, I'm worried that rcu_barrier() is too heavyweight and we have
> encountered some hung tasks that rcu_barrier() waiting for callbacks that
> other drivers queued but not handled correctly.

rcu_barrier() wait for the pending callbacks to finish and none of the
callbacks can block, so I don't think it'd be much worse than
synchronize_rcu().  Also, it'd probably make sense to inc
isw_nr_in_flight after call_rcu() in inode_switch_wbs().  Given that
all inodes must be gone by umount, the actual race window isn't there
but that ordering still makes a lot more sense.

Thanks.

-- 
tejun

