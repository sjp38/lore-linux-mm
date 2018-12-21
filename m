Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F189C43612
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:55:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4BA221927
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:55:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="f80lE8Xe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4BA221927
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D71D8E0007; Fri, 21 Dec 2018 12:55:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 585DF8E0001; Fri, 21 Dec 2018 12:55:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4271C8E0007; Fri, 21 Dec 2018 12:55:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F31988E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:55:45 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m13so4539830pls.15
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:55:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:newsgroups
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=bZv0AL8mH/qJBbDmdLu8whpdWxQNWBnu9wuioQub1WA=;
        b=sVfZ9MKpLITh+8xmJNIhx9J5y+qVp1B3igGTnBMiq+cYf0MbN+DHH5p9j8+aZl+pwm
         NAsZqzdKLeLIFcdQY6fqUo5i876FisfXXGRZ6GNZMsTKxH9+DHa/p0Zhudat4M/CK8OS
         rOdBah/Fv7UO8LgAa1jePSXE6FA0gZzBIt61ewpyVxva9je+D/te5o3lQ+IT3ebQCujR
         THcmRjgg4FjwzQLkYGsH68AezOIn5uvekjektuXaSe/f5e0mTmUTr4QPa0C9E8LuoB7/
         tEgdMrNjstjIZwRK7V1W1ntAOmC2o4t+GgapRzRRe65rB+ZyEMBt97FA9PxAn9HFADyt
         yi2w==
X-Gm-Message-State: AJcUukf7TdfwvQNSkSF7GTKcVPJDzPlzL0JKiokLv5iMTfDm/z75GOuu
	df8L89NUZoktssPC6UWpwv77b3C/LFlhbKzsrBSZpSIvq+EjHONQY+XyCFeYxh9XRVnc638+IK0
	Jg8ojOMSO0CqMifYGoczFZajjQAiU5oxIFsZl5AyJxsKoFWTjAmiOQLgTjcgsRNzz6A==
X-Received: by 2002:a17:902:9a4c:: with SMTP id x12mr3412617plv.94.1545414945402;
        Fri, 21 Dec 2018 09:55:45 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4nJeP5oJUKE7ijHNd6v6xglHxnj7OOSU8FRMJw9ANbTNC5Iqnn+MmUZtkqRAzuJT8qO5jn
X-Received: by 2002:a17:902:9a4c:: with SMTP id x12mr3412581plv.94.1545414944442;
        Fri, 21 Dec 2018 09:55:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545414944; cv=none;
        d=google.com; s=arc-20160816;
        b=coN+fjVip1kmcuw3vrEbrrodCMX6cUc3ZuV4Zcl8xYoEc/yT7Q//1GyVdw4TIOhqDj
         9rRrW41MOlAhxBiprM5iA5G7vUv7buwK2hLwATeTIwtBu/2OQ7h0Q+ek6gGVIHY94ObL
         E3GWOagM9j61za56fH3Ll0XMvVp+buwusKD8Br5qnddK1RKAPhNMKYM6XyKREyJSqOit
         4gU1dYwxdSbHPJRfRPTnSZFUjrtnnjdlPISeJpun29lKF2HHwaGG8h2ecvQcssMxiTFx
         i64EpDewMvSqsYpixwSIzgKpcNHkMOKhzWwM78nfz+Uz2BdqjYnlM+lADz5lDBfgXcTC
         +y/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references
         :newsgroups:cc:to:subject:dkim-signature;
        bh=bZv0AL8mH/qJBbDmdLu8whpdWxQNWBnu9wuioQub1WA=;
        b=FL6hH827PFyIF9ECiNM722H7SNLsBN9X3N5YWSzr5SdyYEhDgtOzMVhs323WQX+CHn
         pIxnn1LQZEVykRzyQ4JNrHoP3hbnKJ5iij2uab6DKLSAJpQ3Oz0HdJmDg3fGUCcAy3Sk
         NVQoj7aD7MVA18hbCZB75pBxdoyWe39H9CVEROPVBwyILxa4c2xADmZ9Fa8Bw1B9cNgL
         8VX4aYrEdu1G3YAooIHlyh5qjJ5YttzBsd4U49RTZcwX5ICNrBOHXh8ZQS8RVRFkZeVD
         FzX2BiBt9xrpDlqwgzeRXUlqsT/q1P1MZAphEvLirDsWO72/bdYJ/baRTX9etnsvxgP0
         B0Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=f80lE8Xe;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id j2si20433244plt.93.2018.12.21.09.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 09:55:44 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) client-ip=198.182.47.9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=f80lE8Xe;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (mailhost1.synopsys.com [10.12.238.239])
	by smtprelay.synopsys.com (Postfix) with ESMTP id BF45B24E1148;
	Fri, 21 Dec 2018 09:55:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1545414943; bh=7VjNw0+OZA4YTTEp9sF3S78XPE4vY6h9OZWobD8nMWg=;
	h=Subject:To:CC:References:From:Date:In-Reply-To:From;
	b=f80lE8XeUySSmbHHL2EXqbP7Crk6ufPATuuejekecvOganUaLyYdTW7BB1OGoSCrK
	 pbr8wrFBN67Fhq8esARaaYn8SbSjivXL1RMAaSjCAFG49mrcGuXt+o+JwLz8RPbC9G
	 csOnow8i4gCmET6ox0I762enjs5VLHpm+5QTygfdDs9gOGnirLUkSApWVZ9WBiBY3D
	 XkwPMDEVQ0ZmlvZrgLympuvd4/yEWgzeEnai/6AS/uATFNN5P97xsdHJtABgyRx+lP
	 AKdEyb7LWzxUw4g/CxR28iM4i2EG5ys+y8fRpcOD6EVIZoQKulT9kc4UWgyElazvza
	 wAlQSJxqYT77w==
Received: from US01WEHTC3.internal.synopsys.com (us01wehtc3.internal.synopsys.com [10.15.84.232])
	by mailhost.synopsys.com (Postfix) with ESMTP id 8FC7D538E;
	Fri, 21 Dec 2018 09:55:43 -0800 (PST)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WEHTC3.internal.synopsys.com (10.15.84.232) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 21 Dec 2018 09:55:43 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 21 Dec 2018 23:25:40 +0530
Received: from [10.10.161.70] (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 21 Dec 2018 23:25:40 +0530
Subject: Re: [PATCH 2/2] ARC: show_regs: fix lockdep splat for good
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org"
	<linux-arch@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>
Newsgroups: gmane.linux.kernel,gmane.linux.kernel.arc,gmane.linux.kernel.mm,gmane.linux.kernel.cross-arch
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
 <1545159239-30628-3-git-send-email-vgupta@synopsys.com>
 <20181220130450.GB17350@dhcp22.suse.cz>
 <C2D7FE5348E1B147BCA15975FBA23075014642389B@US01WEMBX2.internal.synopsys.com>
 <20181221130404.GF16107@dhcp22.suse.cz>
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Openpgp: preference=signencrypt
Autocrypt: addr=vgupta@synopsys.com; keydata=
 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
 hhqBJlyU6MVUa6vZNv8E
Message-ID: <8b3739f1-a7d5-7253-362a-3a1c707b0f6d@synopsys.com>
Date: Fri, 21 Dec 2018 09:55:34 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20181221130404.GF16107@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.10.161.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221175534.RKFbjKmOPCwT0q3_THoW3DZMsGEzrGxSnk_NSaUJFzI@z>

On 12/21/18 5:04 AM, Michal Hocko wrote:
>> I presume you are referring to original commit, not my anti-change in ARC code,
>> which is actually re-enabling it.
> 
> Yes, but you are building on a broken concept I believe.

Not sure where this is heading. Broken concept was introduced by disabling
preemption around show_regs() to silence x86 smp_processor_id() splat in 2009.

> What
> implications does re-enabling really have ? Now you could reschedule and> you can move to another CPU. Is this really safe?

From initial testing, none so far. show_regs() is simply pretty printing the
passed pt_regs and decoding the current task, which agreed could move to a
different CPU (likely will due to console/printk calls), but I don't see how that
could mess up its mm or othe rinternal plumbing which it prints.


> I believe that yes
> because the preemption disabling is simply bogus. Which doesn't sound
> like a proper justification, does it?

[snip]

> I do not follow. If there is some path to require show_regs to run with
> preemption disabled while others don't then something is clearly wrong.

[snip]

> Yes, the fix might be more involved but I would much rather prefer a
> correct code which builds on solid assumptions.

Right so the first step is reverting the disabled semantics for ARC and do some
heavy testing to make sure any fallouts are addressed etc. And if that works, then
propagate this change to core itself. Low risk strategy IMO - agree ?

Thx,
-Vineet


