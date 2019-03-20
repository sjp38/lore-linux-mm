Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20394C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 03:46:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4D6620857
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 03:46:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4D6620857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=jonmasters.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2477E6B0269; Tue, 19 Mar 2019 23:46:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CFC06B026A; Tue, 19 Mar 2019 23:46:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0708D6B026B; Tue, 19 Mar 2019 23:46:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CCADE6B0269
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 23:46:13 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id w134so19660175qka.6
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:46:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=4mXctwfeceb5iGjKmJZ/oZnb6KDanwRXZeVOkMlGhY4=;
        b=rNOQ9vV5erwCbm7PSsEPYRC/Qo4HRChNjwkHvoSnQEHwCh4vsMY6ya3H2RtTytXcZL
         iNKNqt5SYWHlNl1TEhL9NIFqgjJliuDVHVq7xYsBEMl82IuK5E4hAetlcU2BA4NlfSvO
         1OxToYasL5uTaJsIGm8GK/sZC7Y94ZNtHAD5OCrqSuz0mooLki0SuU7I0R9ggRAuNxTo
         JQzuUQ+fdKTzfcvHf3ipRRE+++nG2MZ5D1FNxY7jHXrcTOcpp30u2bn0IaUfmBEwj3Al
         d+DTqc8xgAXJs/qnYuL0/YIdBOySBDQdMfKjApq1wEU1555up4sJ8AxUuJiZAW3sj78E
         2zjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) smtp.mailfrom=jcm@jonmasters.org
X-Gm-Message-State: APjAAAXwHYJ4M6cyWhSt95FFDl32DGUfxVmaO5IA82wrRYDzpVO2PkKD
	E8hsQR1EIGT97zQt0JeS4DlyZSOFjrlfcaiepEN36TlqsvAKBv1MUvyloZtgxfhYt2tonuOdHts
	/PHaEZNMYShFh9Xbdsq0D/BQ/omNU+MCaYWV7EcqYcjvz9maDMLAxs0AkC0z31BAmjQ==
X-Received: by 2002:a37:b345:: with SMTP id c66mr4440032qkf.219.1553053573505;
        Tue, 19 Mar 2019 20:46:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFmXo/llNeYl1pAbEdhDj4ycdVqFzEpLKgEBU7azP5O5HfwqXmtYo2hVEuuSZphJPfSbHJ
X-Received: by 2002:a37:b345:: with SMTP id c66mr4440008qkf.219.1553053572545;
        Tue, 19 Mar 2019 20:46:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553053572; cv=none;
        d=google.com; s=arc-20160816;
        b=A8GHRR/Bv7TKQhX2ZoYqa8kFOxEwsY5svMdjiDJ+Q4N8pNVRuwtcAKWJoGgpt0wyKZ
         Dz2H8fxSdvGTCYRr+ZK0zEYvfrNecKkxyFpxn6Iqa8lO6ZX5ybRY5vwtsJbHRoqTaMZT
         g+v8sKVQaChpvqYoPlyZrgQJ8uLBpGZRK5kt08PNJg47VACW/GwdNwMHYYFlGLuUOrQM
         F9rhvfnbtp+Wyv7lpoLxfz+4bNeoLMByv2xclpWTTA6IVx4rro3QJrirn4UybZdiR2ZJ
         PU6GzHmhtIzvVoflBRO1DPV8BrzutfRqgCW50LqYRjAaWibLaAz6mDuCEf6R9b1uDFlM
         DSGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=4mXctwfeceb5iGjKmJZ/oZnb6KDanwRXZeVOkMlGhY4=;
        b=LSi8/Fd4djzFZoPM/uNGvX2zLSO8ub/O0VKuQuFOJxIURYonsNzh8VYME4Pw+sOqhd
         XTrpeSoChhXM0iH5n4v3QmF/lH7JOvaoXThERliEseyFVMLH1pDJr6ca79bTq79qNfQR
         9pKPKfyeuSAOsgy6nprkDK8a4h6Hnmy5z4p6NeP7um9YJVM2iznk6QU4m+K4YKIyubNQ
         zMGwatASpOsk44fSTha7a5grNj33o0VJWp9PjPve3XZfbA0HpPUJYsYOwqD1g1S/SUNz
         XQ6jW/mOi5PAgSpDkde5tnGpLeAP+TY6dOFIn73YhpLEryarveUNrpjbFrBCjckHtT51
         YDVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) smtp.mailfrom=jcm@jonmasters.org
Received: from edison.jonmasters.org (edison.jonmasters.org. [173.255.233.168])
        by mx.google.com with ESMTPS id g16si343493qvn.151.2019.03.19.20.46.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 20:46:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) client-ip=173.255.233.168;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of jcm@jonmasters.org designates 173.255.233.168 as permitted sender) smtp.mailfrom=jcm@jonmasters.org
Received: from [74.203.127.5] (helo=tonnant.bos.jonmasters.org)
	by edison.jonmasters.org with esmtpsa (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.71)
	(envelope-from <jcm@jonmasters.org>)
	id 1h6SB8-0000AO-R1; Wed, 20 Mar 2019 03:46:11 +0000
To: Greg KH <gregkh@linuxfoundation.org>, Sasha Levin <sashal@kernel.org>
Cc: Amir Goldstein <amir73il@gmail.com>, Steve French <smfrench@gmail.com>,
 lsf-pc@lists.linux-foundation.org,
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
From: Jon Masters <jcm@jonmasters.org>
Message-ID: <79d10599-70d2-7d06-1cee-6e52d36233bf@jonmasters.org>
Date: Tue, 19 Mar 2019 23:46:09 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213195232.GA10047@kroah.com>
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

On 2/13/19 2:52 PM, Greg KH wrote:
> On Wed, Feb 13, 2019 at 02:25:12PM -0500, Sasha Levin wrote:

>> So really, it sounds like a low hanging fruit: we don't really need to
>> write much more testing code code nor do we have to refactor existing
>> test suites. We just need to make sure the right tests are running on
>> stable kernels. I really want to clarify what each subsystem sees as
>> "sufficient" (and have that documented somewhere).
> 
> kernel.ci and 0-day and Linaro are starting to add the fs and mm tests
> to their test suites to address these issues (I think 0-day already has
> many of them).  So this is happening, but not quite obvious.  I know I
> keep asking Linaro about this :(

We're working on investments for LDCG[0] in 2019 that include kernel CI
changes for server use cases. Please keep us informed of what you folks
ultimately want to see, and I'll pass on to the steering committee too.

Ultimately I've been pushing for a kernel 0-day project for Arm. That's
probably going to require a lot of duplicated effort since the original
0-day project isn't open, but creating an open one could help everyone.

Jon.

[0] Linaro DataCenter Group (formerly "LEG")

