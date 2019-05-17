Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9778C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 08:00:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5910520879
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 08:00:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bdwPkfc5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5910520879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89C9F6B0005; Fri, 17 May 2019 04:00:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 873586B0006; Fri, 17 May 2019 04:00:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 789536B0007; Fri, 17 May 2019 04:00:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 15D546B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 04:00:49 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id l26so1280674lfk.4
        for <linux-mm@kvack.org>; Fri, 17 May 2019 01:00:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=E30ZwXceSLrrdqkhZETQJSrFB4D6w8xtvQQj0QSh1bk=;
        b=ddGXENTDfjqQZSpZSR1duR8Ecb+vLEXY/FkXFdeg54M69mbA+kVmSBR6wczdib2et2
         jUO0cDKf8DSY3kFjLiuZ3WiwT/j26U8zNmiv2R03/dmnQ879ef3ZqOQ7xcYGG8MtpyV2
         ZQ3rIMtXCkFpu/UYuw+SQZ/b3Wl4gtcWe5bsf4QXDGgR2s3QCveb1HspZosf7ZDL74vJ
         zTBe8g4vws1AZqENauuDd20RIFgO1ntn0pcxt4eCFxHJbWa1RQXgj1GLPOkOVx+p+98Q
         mg5OjxewiJuyAeTTf0uC1Q188GAnWyKvMwVnEfWa68LwEZBIds7M/ckBS/Q3ilarRVP8
         SBmA==
X-Gm-Message-State: APjAAAW3MENREQGsQvC8+DZDnMYz25owX9jeXac5fKKwvXg7wyWrZY7E
	B2Ztp4cZQBVBnHjt/3hUa4mjLMwIpjsAlcRyXTBmy1gKttq6Pip8VVEn+TDX1yJdGiBzRjob3I+
	jTOTvmsUw1V3Lrbl/JIbL2fXs5eTlXsGIr5/Rzp3oyhhF4aUl+BT1ggwMyLjUu99wmQ==
X-Received: by 2002:a2e:9756:: with SMTP id f22mr6080831ljj.30.1558080048439;
        Fri, 17 May 2019 01:00:48 -0700 (PDT)
X-Received: by 2002:a2e:9756:: with SMTP id f22mr6080769ljj.30.1558080047505;
        Fri, 17 May 2019 01:00:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558080047; cv=none;
        d=google.com; s=arc-20160816;
        b=YF9+rRL/alYtpa3uDo3dX6OjbmP5WyH6j5lDWyjAbZskuRugvJmlMuNaailAPtrEeX
         GPT53mmrj4Ddh68VcUz2kcUPjKGAlsUzaU9RBHIAeHAv4K8chZ7xosx8S/10UOxrli2p
         MzJHVbuUS2St1me26wa0cts23Wp7koheXaM9RN6AbrE2dj8K2OyC/ETcVbbdsoK40R+p
         ohdFAzjSaCNuSHr7zwvdXc65rLgoolxNAQR01oca6gam0G7BhM/mSEs5VVYVuPTmb+ps
         tsIMUVlSP5O2wz4MggJgQTcYeypxvioy4fnzy2EMi/iOH7OVdHM6AbceM/6LSchJpzNl
         +jUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=E30ZwXceSLrrdqkhZETQJSrFB4D6w8xtvQQj0QSh1bk=;
        b=gUVF3jp3HpPNqky+1BfmIb8DenMJFsmC9WCUACle+vgp2MMyWEdREZhEMEzlgbU7Mf
         Dv++KrbqM/hm/9aunuWEmOsCKXo2B0STrvE5/KHOjYHCvPLVyVJV5jxRvfRQklQ2XGEz
         ApuxUCZ2AnoBQjCCTygFe43Ym0bYZ+NCL0mKprIUSVOjmaLzCF1S6vg47M7pONgdBB7f
         0oCA4h7QQtsSovl3EDxvY7ysDwvx2Hrp64nrtjw/2S0Og/9RaR0IG05IsieAoyGLzduD
         DDc3p0WaCaOE2fBMlvYGvIi2nVngB+6BaWQKFvViGXX8gxloDaL5i4b+Sh2S3JVUSN9x
         UUwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bdwPkfc5;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o1sor2592703lfl.41.2019.05.17.01.00.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 01:00:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bdwPkfc5;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=E30ZwXceSLrrdqkhZETQJSrFB4D6w8xtvQQj0QSh1bk=;
        b=bdwPkfc51sJvmJvEEnbkjJeee5dDIVMrgrBcQbEWcuq3Gu7xg4Drx7Sxhgj0S7ifcX
         MHKOMyvUXD9qL1hCSXPCieoxHNgARijo9pvrnOH2EzfYZqXH5Lz7TJtcVndAOVHo4XZw
         rUwn3YonVOZFmAV/YnXpExobHSwnuBBeUq0GSrlLVM4UVA1/PVAvsvs3x6QuHTGJ4yyD
         kKNvUUksj1K0U1tcX4QimvxzelNTM+STaUm5uKCtcO3E7D+UqMhcG3yO+T91qZWg5dD+
         Es9SUG2SdeE2D42NKKLasOMtjhLIsUYe12Is80QapjF0rNGGNHdoPyzrhlywFra9vN0d
         DceA==
X-Google-Smtp-Source: APXvYqyj6/DLX73BQiC/tmB+COsEsDGqOV7JEYLnsSkkybRgysxcV2Grcx3KQm4HBOHGkZXarbVNkw==
X-Received: by 2002:a19:a8c8:: with SMTP id r191mr26781060lfe.85.1558080047145;
        Fri, 17 May 2019 01:00:47 -0700 (PDT)
Received: from esperanza ([185.6.245.156])
        by smtp.gmail.com with ESMTPSA id a25sm1288972ljd.32.2019.05.17.01.00.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 May 2019 01:00:46 -0700 (PDT)
Date: Fri, 17 May 2019 11:00:44 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	cgroups@vger.kernel.org,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
Message-ID: <20190517080044.tnwhbeyxcccsymgf@esperanza>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
 <20190509122526.ck25wscwanooxa3t@esperanza>
 <20190516135923.GV16651@dhcp22.suse.cz>
 <68075828-8fd7-adbb-c1d9-5eb39fbf18cb@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <68075828-8fd7-adbb-c1d9-5eb39fbf18cb@suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 06:48:37AM +0200, Jiri Slaby wrote:
> On 16. 05. 19, 15:59, Michal Hocko wrote:
> >> However, I tend to agree with Michal that (ab)using node[0].memcg_lrus
> >> to check if a list_lru is memcg aware looks confusing. I guess we could
> >> simply add a bool flag to list_lru instead. Something like this, may be:
> > 
> > Yes, this makes much more sense to me!
> 
> I am not sure if I should send a patch with this solution or Vladimir
> will (given he is an author and has a diff already)?

I didn't even try to compile it, let alone test it. I'd appreciate if
you could wrap it up and send it out using your authorship. Feel free
to add my acked-by.

