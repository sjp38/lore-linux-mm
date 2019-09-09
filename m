Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C478C4360D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 00:14:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83C0C20863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 00:14:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=dallalba.com.ar header.i=@dallalba.com.ar header.b="iKA5dImW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83C0C20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=dallalba.com.ar
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDFE16B0005; Sun,  8 Sep 2019 20:14:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B901A6B0006; Sun,  8 Sep 2019 20:14:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA6F86B0007; Sun,  8 Sep 2019 20:14:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0158.hostedemail.com [216.40.44.158])
	by kanga.kvack.org (Postfix) with ESMTP id 89F356B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 20:14:36 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 32AA18243762
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 00:14:36 +0000 (UTC)
X-FDA: 75913460952.22.sugar15_b03037abaa53
X-HE-Tag: sugar15_b03037abaa53
X-Filterd-Recvd-Size: 4205
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 00:14:35 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id f13so11360853qkm.9
        for <linux-mm@kvack.org>; Sun, 08 Sep 2019 17:14:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dallalba.com.ar; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=kTHqjcy/hz0NpGuwkrdn5Hh38zQ2PlegGC8UpYIqnRg=;
        b=iKA5dImWIXbLP2YsCcgvaEZfCSCQWPlZXIrdsoi6NzBf4Eym4af5paMS3oT4nHS9TY
         F/1P3bB4FLSMPpI1mk8uoYR6uJEeAPnjKJst/RTQ2Z3FuSDi24Xo/jd7ekVLyeBDDg+k
         pJRCaBoVu57zORpS7LT7/uE3b5yjnPX9nMhTo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=kTHqjcy/hz0NpGuwkrdn5Hh38zQ2PlegGC8UpYIqnRg=;
        b=RdWa1GWCqBwHRd9BJvJmLDZWba+Bv/w0NevXxvQmpmJRV87OGkxkPV4oNv+66QZryu
         9rEx6wwZ5SRT8SShXY6ugxJ53WvLgEC2IQ0T5fBPEcZ79B4kCG4ybPmkgnjvuGHJ112V
         Q+RJ0AFU4y+cYz8PPufVaYK6thHCm9TFlMc0UII+NKeN5deIn9rZfNBYURuyz21fzpr+
         ipqwI+6IvMIKgh+BhXvtEaoJ5CDL0LKXZ1r1vfMdGzJ1DZiG8SJuEo46hi83DvI0rNi3
         RgiqNbhFisJ0hhhDlyKz8OuGD7v0PR80RhhvKzBmXlp8sf5a0NiqBNKZYVIEB8mzc/CI
         XpeQ==
X-Gm-Message-State: APjAAAVoHrjlzU04uWg2R+BdxfuavBksr00hJNDUc52BqXvF0HJXKnKi
	sCvitrHX7HwK1ntcf3JYUzbm
X-Google-Smtp-Source: APXvYqwwJK3wbKY7i82Z4i8chBXHEGrz5c3JroE7oCwUTo64LTe2Xd1auUQVbFb4QPQQtDj2JSZhIA==
X-Received: by 2002:a37:a550:: with SMTP id o77mr21299450qke.205.1567988074766;
        Sun, 08 Sep 2019 17:14:34 -0700 (PDT)
Received: from atomica ([186.60.161.157])
        by smtp.gmail.com with ESMTPSA id d13sm5379034qkk.129.2019.09.08.17.14.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 08 Sep 2019 17:14:34 -0700 (PDT)
Message-ID: <501f9d274cbe1bcf1056bfd06389bd9d4e00de2a.camel@dallalba.com.ar>
Subject: Re: CRASH: General protection fault in z3fold
From: =?UTF-8?Q?Agust=C3=ADn_Dall=CA=BCAlba?= <agustin@dallalba.com.ar>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Seth Jennings <sjenning@redhat.com>, 
	Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>
Date: Sun, 08 Sep 2019 21:14:31 -0300
In-Reply-To: <CAMJBoFNvs2QNAAE=pjdV_RR2mz5Dw2PgP5mXfrwdQX8PmjKxPg@mail.gmail.com>
References: <4a56ed8a08a3226500739f0e6961bf8cdcc6d875.camel@dallalba.com.ar>
	 <3c906446-d2fd-706b-312f-c08dfaf8f67a@suse.cz>
	 <CAMJBoFNvs2QNAAE=pjdV_RR2mz5Dw2PgP5mXfrwdQX8PmjKxPg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

> Would you care to test with
> https://bugzilla.kernel.org/attachment.cgi?id=284883 ? That one
> should
> fix the problem you're facing.

Thank you, my machine doesn't crash when stressed anymore. :)

However trace 2 (__zswap_pool_release blocked for more than xxxx
seconds) still happens.

> > > =====================================
> > > TRACE 2: z3fold_zpool_destroy blocked
> > > =====================================
> > > 
> > > INFO: task kworker/2:3:335 blocked for more than 122 seconds.
> > >       Not tainted 5.3.0-rc7-1-ARCH #1
> > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > kworker/2:3     D    0   335      2 0x80004080
> > > Workqueue: events __zswap_pool_release
> > > Call Trace:
> > >  ? __schedule+0x27f/0x6d0
> > >  schedule+0x43/0xd0
> > >  z3fold_zpool_destroy+0xe9/0x130
> > >  ? wait_woken+0x70/0x70
> > >  zpool_destroy_pool+0x5c/0x90
> > >  __zswap_pool_release+0x6a/0xb0
> > >  process_one_work+0x1d1/0x3a0
> > >  worker_thread+0x4a/0x3d0
> > >  kthread+0xfb/0x130
> > >  ? process_one_work+0x3a0/0x3a0
> > >  ? kthread_park+0x80/0x80
> > >  ret_from_fork+0x35/0x40

Kind regards.


