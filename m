Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F821C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:14:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6FC52184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:14:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6FC52184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=jonmasters.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 894FA6B0003; Wed, 20 Mar 2019 02:14:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81CCD6B0007; Wed, 20 Mar 2019 02:14:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E5F36B0008; Wed, 20 Mar 2019 02:14:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD196B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:14:13 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b1so1365547qtk.11
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 23:14:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=UwM2hoiQE1eVOFl1C3NwC7C32T3sgwZHVAJ+JA79c44=;
        b=KaiusY+6NrZEHcUQduoguDu8s+jo0eKQjZI3xjV6qYB6KOfF4733rvYElBKOE4I7uy
         pJzKtGTujnmcq1V2ATsIURtiTNYD/quL6nz/+KEpNvYNXIkDEOi6LJMvbhLZsaxiI9uN
         WKUTlJByvz8tXMWqOCBdz72u1oVCunhMfTEe+c+ZFRwtVlTUETEzs5dUHQ0lubMeJx9A
         ZTl+OoUBoBS6kX89odijpca+CoNii2OIV9OELrEUmGpqX3DMgfZ/sR3dibu6avRQWtvo
         XV0J7PF01QicahYFjjh5ko9tvOVPCh3Rt7W5u9zic9R6y3QZTQOebNvnpiayCh86Gdp/
         Kjag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) smtp.mailfrom=jcm@jonmasters.org
X-Gm-Message-State: APjAAAV8v9QojYhau9xVX4aM5lL9Bq6cakauYoM3dUXxF8iQnqstU5r5
	FsNOB4WGsgWwe9CkEVx9op86IdkQajvfdE5J8uVBlcYK7mlc4HfJOuaIKD17Qb3n+q/sGE/ZB9r
	rthS5RtghxxzTMslDK9U7E5qdyFSjtMx887YJN3eKM9uP9OYlnyTHXOwWOjODFSFnUg==
X-Received: by 2002:a37:9bd4:: with SMTP id d203mr5193129qke.58.1553062453080;
        Tue, 19 Mar 2019 23:14:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIZop24+hSnfdyvF0BOKgeytxAVM+GAsBrCSua0cFOJs8ArOxEG2y6/vH0Ajy5lMBvu5hC
X-Received: by 2002:a37:9bd4:: with SMTP id d203mr5193093qke.58.1553062452286;
        Tue, 19 Mar 2019 23:14:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553062452; cv=none;
        d=google.com; s=arc-20160816;
        b=xSCbF3oKkiuFi3yC75jQCX2XpSwyywLSL+tX4402gDE/qe9R+ewEbwmR2yX0n6CWtJ
         d7nFKOZcQcvzxqyEvXA1XAmfIB/vtEp2Q3eOAkg+ADbtunU1Ze8jjoeNcSxseTWJcBPu
         m9WQgBrLgUHNfTyjEw9F8DcDFmGj+1jKEO6TE+z2woQw9rkOcMy6hSC7EU3kw20mGb7s
         HtHIVImRHyAeF0+6ZUNcN4OzEaiZRmMCCoRMq8dVpJauwu2f7XngfmbgR+83XcyLOR5D
         fPUk3WNTP4s8l3DNinR2/mg7IKvQct9sOd005+9L7s1QuN/vsItvszd0K3qrPlJ8XLO8
         1zKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=UwM2hoiQE1eVOFl1C3NwC7C32T3sgwZHVAJ+JA79c44=;
        b=zFndcn2pP3sCgq2cAHNHOqxLKHb6rnSjOtOTnQFIVXH5VZb78EyDKBcsuU3sPqMHQ6
         6GdE320SK1uLTM9FAogSw1AjAWrVvQMGCSsajRlaTl/ayMJYqRT2VXSwbbuivuZaUfdb
         wB8av1zm6mby3J3v1Z0bAiUSOp2GD3u4Urdj8+lKEqMRwS3n8KVk96DPzSsfO1OqGzMz
         XJLb9F8XP7mJ9Wryz6IeW+BV0mum69sHUE3+Hpuinf7SPL+8IiLx8M3BKMHTF6R3SeV/
         vE2/9l9SaPJ9TYTDrEpHnI5ewMinzcHuz5PJJFMu9tGXQ/bPiOTsWf+XkEBmzI0MPEWm
         Kf0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) smtp.mailfrom=jcm@jonmasters.org
Received: from edison.jonmasters.org (edison.jonmasters.org. [173.255.233.168])
        by mx.google.com with ESMTPS id y80si609729qka.106.2019.03.19.23.14.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 23:14:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) client-ip=173.255.233.168;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) smtp.mailfrom=jcm@jonmasters.org
Received: from [74.203.127.5] (helo=tonnant.bos.jonmasters.org)
	by edison.jonmasters.org with esmtpsa (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.71)
	(envelope-from <jcm@jonmasters.org>)
	id 1h6UUM-0001Kh-Bd; Wed, 20 Mar 2019 06:14:10 +0000
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Sasha Levin <sashal@kernel.org>, Amir Goldstein <amir73il@gmail.com>,
 Steve French <smfrench@gmail.com>, lsf-pc@lists.linux-foundation.org,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm
 <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
 "Luis R. Rodriguez" <mcgrof@kernel.org>
References: <20190212170012.GF69686@sasha-vm>
 <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com> <20190213192512.GH69686@sasha-vm>
 <20190213195232.GA10047@kroah.com>
 <79d10599-70d2-7d06-1cee-6e52d36233bf@jonmasters.org>
 <20190320050659.GA16580@kroah.com>
From: Jon Masters <jcm@jonmasters.org>
Message-ID: <134e0fe1-e468-5243-90b5-ccb81d63e9a1@jonmasters.org>
Date: Wed, 20 Mar 2019 02:14:09 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190320050659.GA16580@kroah.com>
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

On 3/20/19 1:06 AM, Greg KH wrote:
> On Tue, Mar 19, 2019 at 11:46:09PM -0400, Jon Masters wrote:
>> On 2/13/19 2:52 PM, Greg KH wrote:
>>> On Wed, Feb 13, 2019 at 02:25:12PM -0500, Sasha Levin wrote:
>>
>>>> So really, it sounds like a low hanging fruit: we don't really need to
>>>> write much more testing code code nor do we have to refactor existing
>>>> test suites. We just need to make sure the right tests are running on
>>>> stable kernels. I really want to clarify what each subsystem sees as
>>>> "sufficient" (and have that documented somewhere).
>>>
>>> kernel.ci and 0-day and Linaro are starting to add the fs and mm tests
>>> to their test suites to address these issues (I think 0-day already has
>>> many of them).  So this is happening, but not quite obvious.  I know I
>>> keep asking Linaro about this :(
>>
>> We're working on investments for LDCG[0] in 2019 that include kernel CI
>> changes for server use cases. Please keep us informed of what you folks
>> ultimately want to see, and I'll pass on to the steering committee too.
>>
>> Ultimately I've been pushing for a kernel 0-day project for Arm. That's
>> probably going to require a lot of duplicated effort since the original
>> 0-day project isn't open, but creating an open one could help everyone.
> 
> Why are you trying to duplicate it on your own?  That's what kernel.ci
> should be doing, please join in and invest in that instead.  It's an
> open source project with its own governance and needs sponsors, why
> waste time and money doing it all on your own?

To clarify, I'm pushing for investment in kernel.ci to achieve that goal
that it could provide the same 0-day capability for Arm and others.
It'll ultimately result in duplicated effort vs if 0-day were open.

Jon.

