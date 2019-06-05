Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54270C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:53:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13C7D20870
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:53:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O84ji0lX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13C7D20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2F5C6B000D; Wed,  5 Jun 2019 09:53:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEAD26B000E; Wed,  5 Jun 2019 09:53:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CD4A6B0010; Wed,  5 Jun 2019 09:53:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 784B16B000D
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:53:23 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 18so6579314qkl.13
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:53:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FETSS3J4eD7K515d8ScmcKfF1wyotHso7dwlnNKYVC8=;
        b=aorF+kVJhEwn+UXKIHNkrmXATlp0urflipmdp0KrnQgk73F1rnAU78bNNWneAoqErd
         5VAL3yjiTY/YGnILfuneLVy78cLr0yfI+tJounOd1bF77ruT2lKMU5QpeBmaKR5T/bqR
         lMeLb4+Iy2EWOtNz7os3Cy5bcPywTh1yFKr8myjb5Hg5u4wXUJmmXNYfQ13bAXpsfumq
         H0ZKNJBQ/44v9a4i/3ZWlBz6efE50Ci1uhm9S3GwpcAzSQ8uk4Wb2/VDJu57HcIQxVIC
         pNYGtBG81lr571NkqnhxAn0sEu4IXKvoWtVgzAqbvaZdMGIpp1tm8/hK2IgSc+pjrOIv
         hKig==
X-Gm-Message-State: APjAAAVw261NWpQtzvaedorYHw7ohvm7GUwjGM7QhRwk3Ktq2yP4dDNf
	0nglZY97GGFGof/Cwr0VfQiIsUuqiU1u7R9r2DTX3qiWiEWWJoQvTa94j5giXBW2I17XfSrRXO2
	Qjib7INnn4G9HYMJWbXjgo1gp4IU6Nga/gr+XqYZnzZzcVUVEbBtAg1wVC0j6fLE=
X-Received: by 2002:a37:9207:: with SMTP id u7mr34138190qkd.357.1559742803223;
        Wed, 05 Jun 2019 06:53:23 -0700 (PDT)
X-Received: by 2002:a37:9207:: with SMTP id u7mr34138157qkd.357.1559742802652;
        Wed, 05 Jun 2019 06:53:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559742802; cv=none;
        d=google.com; s=arc-20160816;
        b=ws/zxXz47RC5/atOd7CO+UcXaGrt6FqJhGuubnBhI/I5Ly7Nje61bhYlLLVpNUMIuM
         7NRicewJcc+Ru5fNeKsLbQFHoo4TBlgeQyiGZhc4OCE3ujhKV1chm41Uv8/EHT+HmOej
         9NG801v3AXrwJL9r3ERWYw1POvRCkGALtC+DwaBXOmSukJQWIS+fP63jrZqgmnhswCce
         iSPqxgLXejk4JkZGu+tQu4vEO2rMt0PgpmAkvNlXrcIaL00UT4aHWhlV+CoOhD5hGual
         cyFmb+MyEdjBP+VZLZo/xWFqYEdr8+lT3RelL1NiBimVk5ZYgWCdjBuqahMKM5Buf52O
         eutA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=FETSS3J4eD7K515d8ScmcKfF1wyotHso7dwlnNKYVC8=;
        b=UyxDqruxU6+mMNSJiTRsYyr77HQFRKBh6YPk/jFI3iMfEbxJH4/t68UrABD5ReU9hh
         1GsKnIUh2O4T5cGeD5+VeyBq0M1J82/APNPW/oJnAnROoWjyj4MRkBDDcHrJOZq5myZu
         /evRXDQPcwKAMZPrSQxPEzQP6vaTxaEucHb8WejqSPdoF6tG2gG1/wpF2TC3cPZWsmXs
         SlJQ/RwjcIe1Y5j6MDEV0E1XoZ0pmhrF7s9AddpZDk8hoAjSH1nSBpQ9G8y5Kua8iZhp
         yZXZ1UFtMlex+TdxW+StoeZAh/55V0NF4aCEKMX17lMn2e0j2/JjqCC+iiupjI7OfLrc
         H4dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O84ji0lX;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z19sor4573378qki.42.2019.06.05.06.53.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 06:53:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O84ji0lX;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FETSS3J4eD7K515d8ScmcKfF1wyotHso7dwlnNKYVC8=;
        b=O84ji0lXN+RqkutIEaEyEEqQXcFVzeG64E5D+IGzwBJcDRXFIhtWb80kt89787ERae
         SVgqIrHUOdqzFOWmqqrmY63CyKPgJHTijErg98dUmfPqYT4f200Pa3v2DHmAPP/DgulF
         7nlCPUR8C5qMCx8d5XN1RqshszE7/VRzXBHkrkM8ioHtBsYqvXGLKiUWOF8TgpJfByAC
         WxpTcx4EhwfLIK2ozup8V4g1ahyLKPG66YNnH3iOR2HOqHPyAVljLcZGRtEvSJDYYBBK
         ph5a0gf262q4Ydh7OMHdU6YtIKKeID7muJi8gChJSfg446PN8vB787GwyVShso3Jk9H1
         cbxQ==
X-Google-Smtp-Source: APXvYqzgbDsZ1PJ/Ceon86CDXM/qpmDYa498SwcV19QGw1THKkkoAkdv6IOc/u1X7CTxkAGOqabeTg==
X-Received: by 2002:a37:9ece:: with SMTP id h197mr14387983qke.50.1559742802150;
        Wed, 05 Jun 2019 06:53:22 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:c027])
        by smtp.gmail.com with ESMTPSA id l3sm10177469qkd.49.2019.06.05.06.53.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 06:53:21 -0700 (PDT)
Date: Wed, 5 Jun 2019 06:53:19 -0700
From: Tejun Heo <tj@kernel.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: hannes@cmpxchg.org, jiangshanlai@gmail.com, lizefan@huawei.com,
	bsd@redhat.com, dan.j.williams@intel.com, dave.hansen@intel.com,
	juri.lelli@redhat.com, mhocko@kernel.org, peterz@infradead.org,
	steven.sistare@oracle.com, tglx@linutronix.de,
	tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC v2 0/5] cgroup-aware unbound workqueues
Message-ID: <20190605135319.GK374014@devbig004.ftw2.facebook.com>
References: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Daniel.

On Wed, Jun 05, 2019 at 09:36:45AM -0400, Daniel Jordan wrote:
> My use case for this work is kernel multithreading, the series formerly known
> as ktask[2] that I'm now trying to combine with padata according to feedback
> from the last post.  Helper threads in a multithreaded job may consume lots of
> resources that aren't properly accounted to the cgroup of the task that started
> the job.

Can you please go into more details on the use cases?

For memory and io, we're generally going for remote charging, where a
kthread explicitly says who the specific io or allocation is for,
combined with selective back-charging, where the resource is charged
and consumed unconditionally even if that would put the usage above
the current limits temporarily.  From what I've been seeing recently,
combination of the two give us really good control quality without
being too invasive across the stack.

CPU doesn't have a backcharging mechanism yet and depending on the use
case, we *might* need to put kthreads in different cgroups.  However,
such use cases might not be that abundant and there may be gotaches
which require them to be force-executed and back-charged (e.g. fs
compression from global reclaim).

Thanks.

-- 
tejun

