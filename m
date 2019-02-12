Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4BDDC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:07:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7221E21B68
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:07:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7221E21B68
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 258E28E0002; Tue, 12 Feb 2019 16:07:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 207C38E0001; Tue, 12 Feb 2019 16:07:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11E818E0002; Tue, 12 Feb 2019 16:07:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD2A08E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:07:41 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id l8so112610otp.11
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:07:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RY+t8uEc5Fq+07v8SJmGnmhu1rcVR03Y3OtSDhBprWw=;
        b=TGQkPC7gi7xRfXm75ker1sFDyY+gBRXS3ownJwPbBFWu7Iv6boQH3vNhh66ZenqBPm
         iFfz3mrd3/2caY9JDA2nvBETZf+XBXBtJlXQ13DlF/XA9wj01djrl/XHfmvaJpU4JUVf
         ih87nipSvXavzhq4MVr+BoTyUzZZHojCHXfOfZaMsQNLGo66z+69/9MJOPRha0jsXxNr
         y954e9DtsymO+kNjP0xD3F16FJ8OmJCzEnghtzdGwBxs9WlcjBm033/XwOFOiqzm8EDZ
         Xpn+2AUebiREDuWnxJxXQawZBxAGWrQIK2zzT+DI0BkQvuvoYJK4W2jJtCjURENjtaLx
         KSBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuaSBFkIeMIpQHX3w/9/7mtLA+huLthU00TkV+fLW+JtOGYzzWtB
	Q4+yL+dwkGYODbHecfgU4Xxna0lMNpTvSkLYdLvVqcJwqai8ugV/JYMU/EJUTNKUrPG59n99O0i
	N9m7HufVuV2XRBm9k6Kmt7xMTvSTwn/pdxrMk7Q41a3UCtSqnVznoT7wETKc8ZYr8cw==
X-Received: by 2002:a9d:64cb:: with SMTP id n11mr1047588otl.314.1550005661544;
        Tue, 12 Feb 2019 13:07:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBS6LofgU7d7wnJCg1JYqERFF/hCSXiqWcXqKC8+iDmQK7BnZ+18ERp0WMaQtj/jJKW+8z
X-Received: by 2002:a9d:64cb:: with SMTP id n11mr1047544otl.314.1550005660912;
        Tue, 12 Feb 2019 13:07:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550005660; cv=none;
        d=google.com; s=arc-20160816;
        b=pZjg6eg8xTXszs4nnplkrUOy7PVozR1wmOM0JqPxbXaALimNK71y0m7LJKFH4MEzZ4
         W+Hi3NQtbl3hcWfahVT4qH4hbO1LT6Ce7ILmGKikdW1XMkPfSHDYvcA83wNbeKYaOZuU
         vfS//wlx1YDvmg6AVRekU6CoBet3vWhH2y3Fb4LwMLfbkRTc0esRTaKb90y0Frt0c8mR
         mIJeDfLsbJRp3oZ7qGvW8S5YxNkS/EUiatfUhtNIZV+xQ/Oe5AGiA4p3HKqvVMPaMRNg
         ZxNFXE59tmpcZmAmKZCbNcHxv8JvuyoUdLCb/9JudBsXwLyrVCm3XwnPW0oHInHX1p22
         0amg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=RY+t8uEc5Fq+07v8SJmGnmhu1rcVR03Y3OtSDhBprWw=;
        b=sFZ6OuK4gWWxhvK/6zqB/z4COViG1pv4VD7W/4j3/f5nFakqhKFI/u1V1GfhA0oZcK
         2PYxnaPEuIXx2i5RellAMkGEL9AbOHAsC3DJdXULOZ9hICVPr47MH5v6LpZ194qMPLKz
         Z8PquOqgsnjk6+V2RkgXr1CNVMI62TwyGcCk256Pf9eB2ACwemKC1OXRRydoQzAIrK/p
         H9dCtIWx2afhokKy9SRiCbRhMkMd5TBB4bfpga3SKdYK8z9j3ew5k5octAhFQ2lZIUbp
         HCP/Xz3MZWPE9rywzjntb3NFq5oMMN8ASI01xFS+AyZgIwXQu8GxxuNFL+P7YyxQrQTZ
         1Ugg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c82si6150444oia.35.2019.02.12.13.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 13:07:40 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav301.sakura.ne.jp (fsav301.sakura.ne.jp [153.120.85.132])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1CL7UsS021116;
	Wed, 13 Feb 2019 06:07:30 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav301.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav301.sakura.ne.jp);
 Wed, 13 Feb 2019 06:07:30 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav301.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1CL7OOv021047
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 13 Feb 2019 06:07:29 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] proc, oom: do not report alien mms when setting
 oom_score_adj
To: Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>,
        Johannes Weiner
 <hannes@cmpxchg.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org,
        LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
References: <20190212102129.26288-1-mhocko@kernel.org>
 <20190212125635.27742b5741e92a0d47690c53@linux-foundation.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <46b3262e-2a9a-da01-16de-14cd4d7eaa40@i-love.sakura.ne.jp>
Date: Wed, 13 Feb 2019 06:07:26 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190212125635.27742b5741e92a0d47690c53@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/13 5:56, Andrew Morton wrote:
> On Tue, 12 Feb 2019 11:21:29 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
>> Tetsuo has reported that creating a thousands of processes sharing MM
>> without SIGHAND (aka alien threads) and setting
>> /proc/<pid>/oom_score_adj will swamp the kernel log and takes ages [1]
>> to finish. This is especially worrisome that all that printing is done
>> under RCU lock and this can potentially trigger RCU stall or softlockup
>> detector.
>>
>> The primary reason for the printk was to catch potential users who might
>> depend on the behavior prior to 44a70adec910 ("mm, oom_adj: make sure
>> processes sharing mm have same view of oom_score_adj") but after more
>> than 2 years without a single report I guess it is safe to simply remove
>> the printk altogether.
>>
>> The next step should be moving oom_score_adj over to the mm struct and
>> remove all the tasks crawling as suggested by [2]
>>
>> [1] http://lkml.kernel.org/r/97fce864-6f75-bca5-14bc-12c9f890e740@i-love.sakura.ne.jp
>> [2] http://lkml.kernel.org/r/20190117155159.GA4087@dhcp22.suse.cz
> 
> I think I'll put a cc:stable on this.  Deleting a might-trigger debug
> printk is safe and welcome.
> 

Putting cc:stable is fine. But I doubt the usefulness of this patch.
If nobody really depends on the behavior prior to 44a70adec910,
we should remove the pointless (otherwise racy) iteration itself.

