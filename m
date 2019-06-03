Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09ADDC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 18:31:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC55726D67
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 18:31:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="LMV4WcMU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC55726D67
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 539E06B0266; Mon,  3 Jun 2019 14:31:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E9F26B0269; Mon,  3 Jun 2019 14:31:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DB2F6B026B; Mon,  3 Jun 2019 14:31:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 022896B0266
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 14:31:26 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g38so10484073pgl.22
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 11:31:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=K1t0RlXiIMoN2V33/2fYI3ssPScnkjcCM8Nqsr+Odow=;
        b=pDyiJMAVCveCeVXH156CwAtjKIWvQppJ/imiiWob+cra2gLpiXR7HVb0R4JpbzKjrq
         XdMBhYK/ywd77agJONPM21vfgcYZHoAEyjJDfUrUNsBRvlTSv29BIXECqn/roe0PYFRs
         EmkZAgtLKwwVP7aTa++fGryLLZk0cL0X1YMFnzUNatUBVtcS0HbQAd2ow09R+gH+ztzf
         mfHx0K/+QjYelZ7j1OpU1exrcKz63wPLh+wbVwSoIEHFFrLJJOoNTnw/Htr9/KMQwOxd
         yuGoXECKoKjFAeRKEHmvo61Klyeqyf0yk3yK+qQI/L0fWC0RRVrEkL21cCzVfAezWNMv
         QlmA==
X-Gm-Message-State: APjAAAUcwkIyx4NCnSiUAGOfiaNW8coQJAd5zWw4Bs5ASida7EDHU/As
	HXiWnNai35CCiIYdsmRZfFA91eygMlan1WxA2RLPt7lOzH32TQbe9BFdjDny34hLea8/qE2+IVZ
	UjOTtiZDoCvlwjkr8vpz8kcQUxLcwWjjhvneauM7KSKgecXWnlZCdFVucEEQtJdkeFw==
X-Received: by 2002:a62:160b:: with SMTP id 11mr33090552pfw.30.1559586685653;
        Mon, 03 Jun 2019 11:31:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxC9uB+TuquEUxVY0WVpAOJvToKY4RrNvQF6mG4jLCA+BPVODNoS3uB4e/bPtlXXyShIXwI
X-Received: by 2002:a62:160b:: with SMTP id 11mr33090476pfw.30.1559586684677;
        Mon, 03 Jun 2019 11:31:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559586684; cv=none;
        d=google.com; s=arc-20160816;
        b=oLaiX9Gj7xkKhQXwwGYYwAu7kdlHrCYXzrZQhpOcSriNPnWYj32E/aSXJYrwqeml56
         ouGvNt9QV1LhkEY8Dezcspx/ZA9feHRJQX8TwuEc7BC9EfVU2OnubH+HrtyOV+jsOG4j
         yhaFVrmj+Vx0umAW9W5InzsWAflJW4hbozGAZm8vYbJcyHGfWgWJ3BrjQqpI2rTj/HOs
         n3Ozh5NdUh7yJ1LFsdewEDjFYNnVn8PGkc0sTNCHvIm5GtIDFgw6Xco8bDd6sOJ+/WsI
         llazH/rWQocxVzpg+YPGluKx1PFes8bHS1jUGJIkNTBzgGjgD5yEYC20IIfqv+4EPVOM
         4zdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=K1t0RlXiIMoN2V33/2fYI3ssPScnkjcCM8Nqsr+Odow=;
        b=wwA/VkkP09cK3p+iVMu28LNmn9oLF+u5npUf3XpMVJpjhjK1pgOywNE7nhUVwZE1Yj
         IszkO9UIzFPLe2Mv4QNpsT64DUMwG1wE1Z3lpX83UaxU4w/JmuQD9uGgEqMuhUBHyrhd
         g5zS4//WKmA09hrEwafqJ2GkvwyLCduTYk2TmGJZCS6X09bxYWgRJrTR6W5B1mQ7OmbC
         aR8VyXH1sQFMQOHL4N0Ace1MN97rf4dfdo7m2Q/v5uFIi2u3TVZ1VQT2I1MCYEMdm4o3
         bGd7VONuG6uD9+fr4KAdJr6q+Y3vAhDHiTBvSHly3MQlG0IpjirDaQIyFw/BJ6TedC7z
         Hd6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=LMV4WcMU;
       spf=pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=krzk@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f6si18332806pgs.544.2019.06.03.11.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 11:31:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=LMV4WcMU;
       spf=pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=krzk@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com [209.85.208.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ED57626E6F
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 18:31:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559586684;
	bh=tKu+9YnqIJM7WkSdcJxKhcrVSljhwHnaTXwK03T/uwU=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=LMV4WcMUZELWXQQR0e73PHu/2quC/Tw33p3nhKKIX9SDsD264VVlQXxMFnBVoxqD5
	 Fmsb20qeZkPxCHDqyXzNe4TG7g6aRe+xd15pqHD41tTsQTAGYhiNUOcnG0lXioNcMs
	 LVc9VItMI6RFTLHtF4Aqe5+2Xt7KX0Q02bRVJ4uk=
Received: by mail-lj1-f175.google.com with SMTP id t28so6078590lje.9
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 11:31:23 -0700 (PDT)
X-Received: by 2002:a2e:568d:: with SMTP id k13mr14358606lje.194.1559586682175;
 Mon, 03 Jun 2019 11:31:22 -0700 (PDT)
MIME-Version: 1.0
References: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
 <20190603135939.e2mb7vkxp64qairr@pc636> <CAJKOXPdczUnsaBeXTuutZXCQ70ejDT68xnVm-e+SSdLZi-vyCA@mail.gmail.com>
 <20190604003153.76f33dd2@canb.auug.org.au> <CAJKOXPed=npnfk0H2WUDityHg5cPLH_zwShyRd+B2RS8h6C7SQ@mail.gmail.com>
 <20190604011125.266222a8@canb.auug.org.au>
In-Reply-To: <20190604011125.266222a8@canb.auug.org.au>
From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Mon, 3 Jun 2019 20:31:10 +0200
X-Gmail-Original-Message-ID: <CAJKOXPf3LZuQ5o5sERL_b6+4SfERWyQR0jUaVUJs12m7WdD3gQ@mail.gmail.com>
Message-ID: <CAJKOXPf3LZuQ5o5sERL_b6+4SfERWyQR0jUaVUJs12m7WdD3gQ@mail.gmail.com>
Subject: Re: [BUG BISECT] bug mm/vmalloc.c:470 (mm/vmalloc.c: get rid of one
 single unlink_va() when merge)
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Uladzislau Rezki <urezki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	Marek Szyprowski <m.szyprowski@samsung.com>, 
	"linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, linux-kernel@vger.kernel.org, 
	Hillf Danton <hdanton@sina.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, 
	Andrei Vagin <avagin@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Jun 2019 at 17:11, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Hi Krzysztof,
>
> On Mon, 3 Jun 2019 16:35:22 +0200 Krzysztof Kozlowski <krzk@kernel.org> wrote:
> >
> > On Mon, 3 Jun 2019 at 16:32, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > >
> > > On Mon, 3 Jun 2019 16:10:40 +0200 Krzysztof Kozlowski <krzk@kernel.org> wrote:
> > > >
> > > > Indeed it looks like effect of merge conflict resolution or applying.
> > > > When I look at MMOTS, it is the same as yours:
> > > > http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=b77b8cce67f246109f9d87417a32cd38f0398f2f
> > > >
> > > > However in linux-next it is different.
> > > >
> > > > Stephen, any thoughts?
> > >
> > > Have you had a look at today's linux-next?  It looks correct in
> > > there.  Andrew updated his patch series over the weekend.
> >
> > Yes, I am looking at today's next. Both the source code and the commit
> > 728e0fbf263e3ed359c10cb13623390564102881 have wrong "if (merged)" (put
> > in wrong hunk).
>
> OK, I have replaced that commit with this:

Thank you!

Best regards,
Krzysztof

