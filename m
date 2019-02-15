Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E95ECC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 01:50:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6E6221934
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 01:50:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="BHXRGPVI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6E6221934
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D88A8E0002; Thu, 14 Feb 2019 20:50:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 260048E0001; Thu, 14 Feb 2019 20:50:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 101578E0002; Thu, 14 Feb 2019 20:50:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE1E88E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 20:50:23 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 59so5696047plc.13
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:50:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MPH/7bUwtw5m5LG9NJ+qLwwYz6ENNOlv16ai+BlsMKw=;
        b=F3jMYb0y8+3wxpGuBjowJpcpV/XIh2Aex+ICYa+aX4kl56wV3R4WQFGiVbmv49S46H
         RDmjmGCyBBDWi40kLyHUF764G+BlSOkZsmcPQXRnRiSW5prhKCz+BMM9SQvTlj50ODua
         2W/zu0/AJJdaJLEmfLw7FK8SgtbO37RFT8a9V66YsRoVuCAOY5eqAw20EpUQ0CNQDJuR
         jJ3OXReHQPZ/JS+Z+8ghToRbSa7BTRjN//hemBSjVxKo0ZfYXX+fx7NnRa9zzsB3Lm10
         zxPWSUB+33itw7f79TWJPm7WLO/Xrg9ik8Buvp3a7aPkwN7Yg9Jk0Rn07nJuXWoW9Ei0
         /O8g==
X-Gm-Message-State: AHQUAuYXpI1PyYtNs1SMKdSz2ISMIY8n+0e9jv3xen/HWTCjoJP1BdeR
	BCaemHeh/VRdFjYPgYOtr6xcRoLDLsmRzEdVEYcrBEPhLku5dslFlhrctCWnicN8LwJRq4mSjMk
	VcO6W6iWyvf/QoxGh3GvmK8jrG3I/6SWkOCQF4uAuN3I9kX0Ds6pzXZEpjJYpM9Z3iQ==
X-Received: by 2002:a63:105a:: with SMTP id 26mr2841598pgq.184.1550195423377;
        Thu, 14 Feb 2019 17:50:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZAI0Y+u9yuBGvuNIe8g5BYsbvXObpvbxAE/XzHrh07G5NyLbsgf6EDVu/DccNm+iSukfWO
X-Received: by 2002:a63:105a:: with SMTP id 26mr2841522pgq.184.1550195422118;
        Thu, 14 Feb 2019 17:50:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550195422; cv=none;
        d=google.com; s=arc-20160816;
        b=PjotsuKAgKUbdp0QdhW5P6zVh5KVm3ZIr0/1HAn/cP+MD2dgKB/i5W5s7rXnFsjD+j
         qAHzg3TaK6a8e9mJrK3bc7M6wfQOXbx0ooI6BKxZJUwfwAj8QASrxd56x9xmg6a5/i8j
         sUO1yDlxuaUjgkobCxI/N+oDTMWvFZOtZQ8C5uKD+GRUsHk+/s7KsliiNrhRgymga0mO
         eKlF7dgzLqPQ014JLMiHlRmnB5UiTCr0twm1+pDamJUFivJqmeYBOy3mrIQEV4Yz/vsR
         IqbrQwAkB4df1mC/owgP6pciPb0CFUYi190+qRWRee5vshZxjF/cUANMFFnwcl6OoMVr
         J1jA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MPH/7bUwtw5m5LG9NJ+qLwwYz6ENNOlv16ai+BlsMKw=;
        b=p2OTfNIVfg+TihG5JGKZkkuM6ZqOpHOgLPievu0iQZaqBXAlBD3K7NZ33WG/6rhHWo
         3olBA7NRct/+vr77ECdGkGVdQPvTUU3+vXG0Lz3Fe3Q9BnN9ISsQiI45YVr8HZZFdMmJ
         nMBSn+Co1dtzhdpZxOKAKmwyn52Y0TkN0sV86wlaZ/MqcXX5JKduoGsExEczmk65QoF8
         azlK7S03fKYBsxYMLiY+O4IXL/AzqTFl0vr0iTSu+BhcOAxlcBqER9fdlMOW5qKXERsU
         PlTL9PIShD1HGjfmyuIKhR2wDCtqsE7yWuynYy3JBPtK0jC4zpH6ZOi+klvcYJNjK0W5
         hl7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BHXRGPVI;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r4si3754265pgv.245.2019.02.14.17.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 17:50:22 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BHXRGPVI;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7797A21934;
	Fri, 15 Feb 2019 01:50:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550195421;
	bh=SrpytnwARM1mJLTjr4gqtS19qJrRqNK0e1rIS0pu3BU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=BHXRGPVIG6SLeXma4mzXznz5vji0QPOy5UceOKsYtVWtT9PxZajJbK0XZITkLVJSs
	 7r8U4V69QHZgqfaviUfdqKugSr3hWHgnOhzz6N6LxLbhYgwe/hFHKW2ssPG4Q/qHbO
	 5ffC9IjvkA9uzJI27P0vh9+jws0vmZr/zCbeNlwY=
Date: Thu, 14 Feb 2019 20:50:20 -0500
From: Sasha Levin <sashal@kernel.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Steve French <smfrench@gmail.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190215015020.GJ69686@sasha-vm>
References: <20190212170012.GF69686@sasha-vm>
 <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com>
 <20190213192512.GH69686@sasha-vm>
 <20190213195232.GA10047@kroah.com>
 <1550088875.2871.21.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1550088875.2871.21.camel@HansenPartnership.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 12:14:35PM -0800, James Bottomley wrote:
>On Wed, 2019-02-13 at 20:52 +0100, Greg KH wrote:
>> On Wed, Feb 13, 2019 at 02:25:12PM -0500, Sasha Levin wrote:
>> > On Wed, Feb 13, 2019 at 10:18:03AM +0100, Greg KH wrote:
>> > > On Wed, Feb 13, 2019 at 11:01:25AM +0200, Amir Goldstein wrote:
>> > > > Best effort testing in timely manner is good, but a good way to
>> > > > improve confidence in stable kernel releases is a publicly
>> > > > available list of tests that the release went through.
>> > >
>> > > We have that, you aren't noticing them...
>> >
>> > This is one of the biggest things I want to address: there is a
>> > disconnect between the stable kernel testing story and the tests
>> > the fs/ and mm/ folks expect to see here.
>> >
>> > On one had, the stable kernel folks see these kernels go through
>> > entire suites of testing by multiple individuals and organizations,
>> > receiving way more coverage than any of Linus's releases.
>> >
>> > On the other hand, things like LTP and selftests tend to barely
>> > scratch the surface of our mm/ and fs/ code, and the maintainers of
>> > these subsystems do not see LTP-like suites as something that adds
>> > significant value and ignore them. Instead, they have a
>> > (convoluted) set of testing they do with different tools and
>> > configurations that qualifies their code as being "tested".
>> >
>> > So really, it sounds like a low hanging fruit: we don't really need
>> > to write much more testing code code nor do we have to refactor
>> > existing test suites. We just need to make sure the right tests are
>> > running on stable kernels. I really want to clarify what each
>> > subsystem sees as "sufficient" (and have that documented
>> > somewhere).
>>
>> kernel.ci and 0-day and Linaro are starting to add the fs and mm
>> tests to their test suites to address these issues (I think 0-day
>> already has many of them).  So this is happening, but not quite
>> obvious.  I know I keep asking Linaro about this :(
>
>0day has xfstests at least, but it's opt-in only (you have to request
>that it be run on your trees).  When I did it for the SCSI tree, I had
>to email Fenguangg directly, there wasn't any other way of getting it.

It's very tricky to do even if someone would just run it. I worked with
the xfs folks for quite a while to gather the various configs they want
to use, and to establish the baseline for a few of the stable trees
(some tests are know to fail, etc).

So just running xfstests "blindly" doesn't add much value beyond ltp I
think.

--
Thanks,
Sasha

