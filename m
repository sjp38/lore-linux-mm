Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6189C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:32:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A9E02184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:32:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A9E02184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=jonmasters.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3320E6B0003; Wed, 20 Mar 2019 02:32:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DEF26B0006; Wed, 20 Mar 2019 02:32:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 182036B0007; Wed, 20 Mar 2019 02:32:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E873B6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:32:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id r9so20105668qkl.4
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 23:32:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=whRTyOYq5+q0N+xlMz1xAtpdBot4m/GviHs3X08ep7U=;
        b=XjvgMWNXu6Kt6imYs5rUsE+eiJvRUxXiEYQ6NsFHwWSL2lRAKZmb8VmDwLxe0DP83Y
         xHAB28/euP9Ktr9sRzUW95T3jKxveQSyCzftZDHt5RLHZDSe0oSv8XDKENhIm2AioGXc
         LF6Ma+bIhMzKjKDALVcSfiL8EBp0VEbGDDb+XsbHO6KayiOIp1XLqQd4J4MUDAfySeUj
         Iz1ak0mbVLt2eMelFutm8ieg+07WPIOgx4NR0854N8uNdCijtwhF4fQiHEv/uHTyVKkb
         S7AoE/wSICS6r6L9szUrE4SPWJWsCEfMhD/25BQVIVUsB0lFMMMbo0AXqSZ3hFWeZWai
         8sUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) smtp.mailfrom=jcm@jonmasters.org
X-Gm-Message-State: APjAAAUkH2mJ4lioQEqLXg2tDwto+ZrpfC2Wh7osKmjOYgRs4Y3x0jla
	37OPnuiiaW+K78C6eRbRCnl+vWOuNAIwYN8kyR5yldwmW4iB/a8PaG5IdIJx9Y7mKrYuj8gpSmz
	PSjCxRMsGaqFZOh5YbkSGzK43pWHCqAjzM0lcSdLTc4UwS+OwsoOmzWR7BiEBCZ5O7w==
X-Received: by 2002:a0c:a423:: with SMTP id w32mr5235248qvw.104.1553063550695;
        Tue, 19 Mar 2019 23:32:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2sP9HMXcSeyIQ5ACz6JesiB1YSwCCQwq/8nTSzFnFtaB0Ido7BuyzfMHsgpN3JsaR8TMf
X-Received: by 2002:a0c:a423:: with SMTP id w32mr5235211qvw.104.1553063549771;
        Tue, 19 Mar 2019 23:32:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553063549; cv=none;
        d=google.com; s=arc-20160816;
        b=q0gk6ioIhp0ZZabftaxxII8P47Axc4bLX3g5LkpA1FA6dnkUl++bV8CaAtBk8xcNJA
         8fyK5k+t8VSCEQ1M7QmXmy+czTEuOGgz8r+SjRb07sSYRZ9FWCvxe8A46tDz7MnEZXwo
         okz8HTgMbG8WgFUT1oJUxdKY0zRpUK5r/euK5RirOVbOB8JKSZq7QRrsk0EoX59nY6Ve
         FS5fHjw0gWadLYwxo/yUOz1igRl33OJYKwfg6fYwZqq1J98kxmLMhGgDvlEIeEV5PWVS
         O6TbbUwOu60E8mgxYmH79mLL1+55MjBme93M6dI6t9GN7WC3EocTx7cEpwY1cN8MhPO0
         SCSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=whRTyOYq5+q0N+xlMz1xAtpdBot4m/GviHs3X08ep7U=;
        b=Nbs4YD1HDfpeggOXLsttm1pHmDOoHHZPqvi/bsgOUuDSNyYQBXqPfDdph+gwPIbToY
         ZRXCPKs5+qvTijPyzt4hrwR8Tjj06eNybdykA0lHX7itKWtGbQVvHjw4E5KaS0VnSkML
         xfn81UY+4zg448nlB0amAIsGxZXbWpMIdPuI09Z9qaMBM9eS7Z74cerqzU4Gp0qdNScO
         p+mG0jPBeOYXSnJ3SZSHNBsZw8o+Jbchmyuwm0H7kLa6iCwSPibKmurjcA4EuFrbI/Sg
         8/ZeuNEmWWPYTYgATdaDa2uVmkugtz1RfETVjNJVlnDGd3Milnlw6cNEoz6JYZUO3IiL
         G0+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) smtp.mailfrom=jcm@jonmasters.org
Received: from edison.jonmasters.org (edison.jonmasters.org. [173.255.233.168])
        by mx.google.com with ESMTPS id q26si534314qvh.162.2019.03.19.23.32.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 23:32:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) client-ip=173.255.233.168;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) smtp.mailfrom=jcm@jonmasters.org
Received: from [74.203.127.5] (helo=tonnant.bos.jonmasters.org)
	by edison.jonmasters.org with esmtpsa (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.71)
	(envelope-from <jcm@jonmasters.org>)
	id 1h6Um4-0006jS-Od; Wed, 20 Mar 2019 06:32:29 +0000
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Sasha Levin <sashal@kernel.org>, Amir Goldstein <amir73il@gmail.com>,
 Steve French <smfrench@gmail.com>, lsf-pc@lists.linux-foundation.org,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm
 <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
 "Luis R. Rodriguez" <mcgrof@kernel.org>
References: <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com> <20190213192512.GH69686@sasha-vm>
 <20190213195232.GA10047@kroah.com>
 <79d10599-70d2-7d06-1cee-6e52d36233bf@jonmasters.org>
 <20190320050659.GA16580@kroah.com>
 <134e0fe1-e468-5243-90b5-ccb81d63e9a1@jonmasters.org>
 <20190320062824.GA11080@kroah.com>
From: Jon Masters <jcm@jonmasters.org>
Message-ID: <b9000988-1936-8a36-0bd0-49a0134bb991@jonmasters.org>
Date: Wed, 20 Mar 2019 02:32:27 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190320062824.GA11080@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 74.203.127.5
X-SA-Exim-Mail-From: jcm@jonmasters.org
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
X-SA-Exim-Version: 4.2.1 (built Sun, 08 Nov 2009 07:31:22 +0000)
X-SA-Exim-Scanned: Yes (on edison.jonmasters.org)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/20/19 2:28 AM, Greg KH wrote:
> On Wed, Mar 20, 2019 at 02:14:09AM -0400, Jon Masters wrote:
>> On 3/20/19 1:06 AM, Greg KH wrote:
>>> On Tue, Mar 19, 2019 at 11:46:09PM -0400, Jon Masters wrote:
>>>> On 2/13/19 2:52 PM, Greg KH wrote:
>>>>> On Wed, Feb 13, 2019 at 02:25:12PM -0500, Sasha Levin wrote:
>>>>
>>>>>> So really, it sounds like a low hanging fruit: we don't really need to
>>>>>> write much more testing code code nor do we have to refactor existing
>>>>>> test suites. We just need to make sure the right tests are running on
>>>>>> stable kernels. I really want to clarify what each subsystem sees as
>>>>>> "sufficient" (and have that documented somewhere).
>>>>>
>>>>> kernel.ci and 0-day and Linaro are starting to add the fs and mm tests
>>>>> to their test suites to address these issues (I think 0-day already has
>>>>> many of them).  So this is happening, but not quite obvious.  I know I
>>>>> keep asking Linaro about this :(
>>>>
>>>> We're working on investments for LDCG[0] in 2019 that include kernel CI
>>>> changes for server use cases. Please keep us informed of what you folks
>>>> ultimately want to see, and I'll pass on to the steering committee too.
>>>>
>>>> Ultimately I've been pushing for a kernel 0-day project for Arm. That's
>>>> probably going to require a lot of duplicated effort since the original
>>>> 0-day project isn't open, but creating an open one could help everyone.
>>>
>>> Why are you trying to duplicate it on your own?  That's what kernel.ci
>>> should be doing, please join in and invest in that instead.  It's an
>>> open source project with its own governance and needs sponsors, why
>>> waste time and money doing it all on your own?
>>
>> To clarify, I'm pushing for investment in kernel.ci to achieve that goal
>> that it could provide the same 0-day capability for Arm and others.
> 
> Great, that's what I was trying to suggest :)
> 
>> It'll ultimately result in duplicated effort vs if 0-day were open.
> 
> "Half" of 0-day is open, but it's that other half that is still
> needed...

;) I'm hoping this might also help that to happen...

Best,

Jon.

