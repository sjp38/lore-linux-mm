Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15583C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 09:02:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C005E206DD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 09:02:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C005E206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42A0B8E0003; Fri,  1 Mar 2019 04:02:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D7D78E0001; Fri,  1 Mar 2019 04:02:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A0EA8E0003; Fri,  1 Mar 2019 04:02:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5DC68E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 04:02:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id y26so5032877edb.4
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 01:02:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=+i9QLp838q9sb6cSq3McvbUq6L5Pb7vt7mV4rdJPbZ8=;
        b=kf94USEgiPcBLVn4ZD5okKFfDQqTkN9pgWI7LDDDks8CQh4R734vAvZ5/2pknVepOi
         Bx0u3vbpymHc9MZBSNhqn+Mg19nTuH3iJS5HiUiQEDvMk/STf8ppeJdzDgLGOxknjtxW
         rnnbR/RPYv34KvEJt1mmWxdhJMaO6JKpVOm6JQfWPcDwZLKMkX+kmUT6kPiUY5yS28Ij
         WmQruYzwOfrZhp50XzalID8+0ANObA+VoKkDmlujlCqXEVayyXDvOboBASmhSFLkdmvC
         CF2HRQVeXl25/DqQHAlckxAoS7Cn5r4Sy70AheQCyYnqi5V3Rdrr5rmokIrm7iOPsQyD
         7Gng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWtszbIhQBEcNJAvAVpWdqDUQiFGDHF1uhJDE4uYK7QGVWRvKB1
	JW96Ih6ovP4q4zPM5b/z9ZfR3KFgNOlk8AqhOzGc4VEkIaN2RmLLVjXknTGMM2FZTNwEiE+348W
	Y+B05UYjj+bQWpuJX5vZ5LEfrcP6JfjIOxRCjRXaD5SHzwNzB314LKjdguyfahWXd2g==
X-Received: by 2002:a17:906:7b03:: with SMTP id e3mr2303147ejo.21.1551430948317;
        Fri, 01 Mar 2019 01:02:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqwQERfCaEi/fV8d1SRJDy6Eux7dxm/0mdFLXyK9yCYsuyoet92XD0iAJK4v4AJpqxL7fqsJ
X-Received: by 2002:a17:906:7b03:: with SMTP id e3mr2303099ejo.21.1551430947380;
        Fri, 01 Mar 2019 01:02:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551430947; cv=none;
        d=google.com; s=arc-20160816;
        b=KYEkFEHjrAMk09owUd84XAGYNycUyfI/Kg8TZ9Ya+K5G2lYpVu7lhHDDOKTQYpNOmW
         t/gxHHCnkUICTTuk1eZIoQ+0LX6e6GajFbDAUC/EM6fg0+xLMvdMNZbO10GEd2mEteCU
         cq7J4WS0b8+Q9RcG4TKbihlzXmNmrgJ/qLXAqGbQFHoBFtDDz/0hFRftRoCx/88p3li2
         PcThU9yMFdpI1/W/qhxYVyP0DZjwhp93gSxnm9MDfGCaqX8s3cU1QoYty0bYqPPmt6OR
         ODjbbfDA5LMw9PL5AEtoobdFXwhLLXq/Fsv889+sYJNBx67vKeIYikwWxS292KTpfeYl
         ur9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=+i9QLp838q9sb6cSq3McvbUq6L5Pb7vt7mV4rdJPbZ8=;
        b=LhF+kP8fxkuTGp1BmudwK2eK/nojCSt+O8WO6G3i/0ZYPXSa8tWMLDBIQDq59aGLzO
         qSSXfUp8Bf3f0DfxHmM4iCPIVdqpd27wmw26Zp29Qe37yfGubtglsio9YFB1IYtIKL48
         q7DiTntxrdMmeE5LFbBCSqQbJI7pDc013TanOFPGsN9Fvk/Rnu6JoxWZfXC8/YO2XUHV
         VwCrYatOJueI86fD5T0JZU2/9pvk3YHSQIcH6gYhJypZFbJw8VoR1eZpOe7y3parpIcd
         a+S4zkibMTfFLHyNBGf3z1CJYkj+b+j9vESYzkPZZ90PLiexUrM6fAmGR7ygpa8SAGyJ
         9SWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h15si3689632edb.230.2019.03.01.01.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 01:02:27 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 173D8AF76;
	Fri,  1 Mar 2019 09:02:26 +0000 (UTC)
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Dan Williams <dan.j.williams@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Brown <broonie@kernel.org>, "kernelci.org bot" <bot@kernelci.org>,
 Tomeu Vizoso <tomeu.vizoso@collabora.com>, guillaume.tucker@collabora.com,
 matthew.hart@linaro.org, Stephen Rothwell <sfr@canb.auug.org.au>,
 khilman@baylibre.com, enric.balletbo@collabora.com,
 Nicholas Piggin <npiggin@gmail.com>,
 Dominik Brodowski <linux@dominikbrodowski.net>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Michal Hocko <mhocko@suse.com>, Richard Guy Briggs <rgb@redhat.com>,
 "Peter Zijlstra (Intel)" <peterz@infradead.org>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
 <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
 <20190215185151.GG7897@sirena.org.uk>
 <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <07d4e843-8023-2041-22a7-b5b589f4d2c0@suse.cz>
Date: Fri, 1 Mar 2019 10:02:23 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/27/19 1:04 AM, Dan Williams wrote:
> On Tue, Feb 26, 2019 at 4:00 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>> On Fri, 15 Feb 2019 18:51:51 +0000 Mark Brown <broonie@kernel.org> wrote:
>>
>>> On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote:
>>>> On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:
>>>
>>>>>   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
>>>>>   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
>>>>>   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
>>>
>>>> Thanks.
>>>
>>>> But what actually went wrong?  Kernel doesn't boot?
>>>
>>> The linked logs show the kernel dying early in boot before the console
>>> comes up so yeah.  There should be kernel output at the bottom of the
>>> logs.
>>
>> I assume Dan is distracted - I'll keep this patchset on hold until we
>> can get to the bottom of this.
> 
> Michal had asked if the free space accounting fix up addressed this
> boot regression? I was awaiting word on that.

I'm afraid it couldn't have. Bisection identified the "enable all
shuffling" patch, but the free area mis-accounting happened regardless
of shuffling being enabled. And if dropping the "enable all shuffling"
patch stopped the problem even before the misacounting fix was merged,
that's another confirmation.

Is it possible that the platform silently depends on large contiguous
areas without a proper CMA reservation, and the shuffling fragments
them? Or maybe the CMA reservation happens too late?

> I assume you're not willing to entertain a "depends
> NOT_THIS_ARM_BOARD" hack in the meantime?
> 

