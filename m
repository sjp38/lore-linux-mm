Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3848C43444
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 20:43:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC426222EB
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 20:43:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC426222EB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 518CA8E012D; Sat,  5 Jan 2019 15:43:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A05D8E00F9; Sat,  5 Jan 2019 15:43:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 341F88E012D; Sat,  5 Jan 2019 15:43:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CAD4E8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 15:43:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so35910199edb.8
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:43:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=NTsGDWwk+E2USt4Or8EEU91aZirfMGT5Vi4b7SBFIlg=;
        b=mH/Y/XEBbbXUXj/exM42ftBRpp0klFcAVkHpZexbnP9ujmS8E/qCK9RI//7VVS2ZHD
         0YXNOIGS3c9FwTKtAgodOMolFqQoxVEFMPSPQvktz53TrcAfyDqIiPR0qGdKeHR4f9Et
         ZQf97I1BtHKmAVUwCn3CEWPwLcbwlqxfrprY6mqo0sRZHSZdOISJ3RKWPByUm5nUgg8t
         xOoPsCHpKRvxuOjgRzybZDzwsE9rDXmlZ2xzdpeVM0Tq5yoaqhUfVnLyFA+tCRicZ30y
         Kvz+CaaxhNO4SYUb8Z5tXD8XtL0XAdw9NU+qXP91ggRXSDAImEWcEvox42Jq11O73JY0
         NjYg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AA+aEWbCVRnV8HPqdelwJWGPa2QBQHTd55XyCWdtUqAbBA7sax6PYIhH
	V7WLeL4uUbX2WG9CqhpQwOeUSaYlCmOSmsVctJEHoxXEmUn7fzJkXMbaNrL3P1HxMAziLHdyMBk
	ec95FwQsTlQJn8ZcS0vU4A1sADg1RWWDj3zV5nIwfhU6Xj9ZgNhTLjBshlx+vIf0=
X-Received: by 2002:a17:906:cb2:: with SMTP id k18-v6mr43075928ejh.129.1546720986348;
        Sat, 05 Jan 2019 12:43:06 -0800 (PST)
X-Google-Smtp-Source: AFSGD/WPBFYMpyL+KrMIDZWRsZCawiY8Y1anQz8kmu5ENAtIHKLCu9YoKsw1vcklrAO/m0+uZc7W
X-Received: by 2002:a17:906:cb2:: with SMTP id k18-v6mr43075909ejh.129.1546720985460;
        Sat, 05 Jan 2019 12:43:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546720985; cv=none;
        d=google.com; s=arc-20160816;
        b=yqmexDezgY44nHE5Hr6/oCKqZNj3GmOyRp9xSO9kY7Eb0upV3UsUQuvdGSR2VCcGFa
         86AiLeQ5AHGNy7em+ZxAP6mNpxa7+7Kxokcg4yVCreoxwz/HMgIF8JPNso21c/o8OJYR
         U7CQ3QwjW8ql92CI8Lcom1efOaKWOHfjXH3IviCS1JQ1WPewSiBgMcXJ/rSWd6Gqcxnh
         l/e0JocZ++gSAilTKwUgsyicpYPJfqAji1LzNTaqd8IQNNplvFX2dMXNy8QhVFNcbLbR
         DulaXSicBz/ZSzDmRWXSlb194lJzLmuKgbeRpDjQ2EqA/WP9CwpOTdnqaU2yytaCiL/L
         Wk9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=NTsGDWwk+E2USt4Or8EEU91aZirfMGT5Vi4b7SBFIlg=;
        b=V8ESRty6jD8nwEv7QsTHiIR/aPFDstYVEGJiVh0w1FkyeSpAzUtFylMsQHVPRBkU1p
         HGM9Nl4Eg2ONySEziDqZ2a2q/0RSx+8Lf1nmAKYJklMc4z5tg4UtbWMcCAe0g5snbiWp
         8jVgi8RMeeo/nbTDj4goKtY/4Vpasf6MhJBfjCzUD5eMUOn3VbokZ7lKQ1vO3crnWR28
         cAzr0XnGOY4LuLR04vnkOfAtCCtB1wRJVUAdBIS0Af7xCeid9S6fA/9ixWqGpFzSVi9d
         0AkGWQ4RdCllQb1yw0ktLXlL1DDGU8RcGuARjATGJfcLVSE9LukBSxHeJvqlNNlwD8A1
         Ixag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18-v6si3437041ejz.304.2019.01.05.12.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 12:43:05 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 92417AF64;
	Sat,  5 Jan 2019 20:43:03 +0000 (UTC)
Date: Sat, 5 Jan 2019 21:43:02 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    linux-mm@kvack.org, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    linux-api@vger.kernel.org
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901052131480.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com> <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm> <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105204302.r5a6u3D-wxgg7PaJolK9zDrU4se5ZXNbjsjWLD2BfTo@z>

On Sat, 5 Jan 2019, Linus Torvalds wrote:

> > I am still not completely sure what to return in such cases though; we can
> > either blatantly lie and always pretend that the pages are resident
> 
> That's what my untested patch did. Or maybe just claim they are all
> not present?

Thinking about it a little bit more, I believe Vlastimil has a good point 
with 'non present' potentially causing more bogus activity in userspace in 
response (in an effort to actually make them present, and failing 
indefinitely).

IOW, I think it's a reasonable expectation that the common scenario is 
"check if it's present, and if not, try to fault it in" instead of "check 
if it's present, and if it is, try to evict it".

> And again, that patch was entirely untested, so it may be garbage and 
> have some fundamental problem. 

I will be travelling for next ~24 hours, but I have just asked our QA guys 
to run it through some basic battery of testing (which will probably 
happen on monday anyway).

> I also don't know exactly what rule might make most sense, but "you can 
> write to the file" certainly to me implies that you also could know what 
> parts of it are in-core.

I think it's reasonable; I can't really imagine any sidechannel to a 
global state be possibly mounted on valid R/W mappings. I'd guess that 
probably the most interesting here are the code segments of shared 
libraries, allowing to trace victim's execution.

> Who actually _uses_ mincore()? That's probably the best guide to what
> we should do. Maybe they open the file read-only even if they are the
> owner, and we really should look at file ownership instead.

Yeah, well

	https://codesearch.debian.net/search?q=mincore

is a bit too much mess to get some idea quickly I am afraid.

-- 
Jiri Kosina
SUSE Labs

