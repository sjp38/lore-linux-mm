Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7578C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:40:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94209217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:40:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UVfexhYQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94209217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D8F18E0005; Tue, 26 Feb 2019 00:40:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1871B8E0002; Tue, 26 Feb 2019 00:40:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09D598E0005; Tue, 26 Feb 2019 00:40:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id CEA928E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 00:40:35 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id e9so9733574iob.4
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 21:40:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=cwd5WKENydJd1AJ9VjYkBwcxB6cS9K+hKRcVy4TnBYU=;
        b=in4o/DwgGb75hDf2qSXz4YFxAQTtv1y+Y4g1x9kuwwACxOKteUhX1/Ym8jirWGy9e5
         auphsjIdCWtbyoLwtBG7CHf2G2exOJi6VrT7tJC4R9RCEUzHDNG9CXyY+jinaZh6k2YP
         HAaI1vBm2JwIOakHq+KfKN7vEIHipxGhBkymbq4qbtPfa07t56oSPp9uP/PFHPRulWYf
         aSbvYPMct+3XyhieUhdJF3JaXWETPmmXwin7EKG2E2Q9oGw2NnSbeZcZf7/DXWLkHdjg
         fxI++uwsu50TU79aNVwztNDkjP2Pq1B60n5DIWXt3DPe3I756XQhQhpbc3l2WdqGORRp
         r6iA==
X-Gm-Message-State: AHQUAuYoi3ZQugjrCtA3mldFUFwPZVtiv46XvH2tDzsNPQIap/FBooM4
	tLp465RltWep5D8fkC0ZYBrEyuJGGd8V3YN43XuDp/4myt6i41bNFTTmYtWpiSHJeRQbHj8NFu7
	e49V9+EKUK905jZVYuHHgCPXR6Q0xGpF22Wh+l6Ihboyp4sqelamzZSQZrC/LjMvXw2xGMOY3K7
	/dJMtm5BL9CLJfek26QrcdJz77SLErixkpXJ4RoX9ezxFiQIrVAwcQXiKAwQmvkCjPNFQ+E0qYX
	xGAiZ0YEnFCum1ED3fqHhHG03AVn8NBFN3lfBXNRxcSUetaCLu0r4++dHB9co80lshI5me1Ulsy
	GVbr7607mO4bx/tYVj407dpID6RlZ9UAR1XIj7XEzsiCJ7DVu5pZXjGdW3Ouc+7KU4YWC8V+qqb
	D
X-Received: by 2002:a6b:c543:: with SMTP id v64mr11811743iof.6.1551159635535;
        Mon, 25 Feb 2019 21:40:35 -0800 (PST)
X-Received: by 2002:a6b:c543:: with SMTP id v64mr11811726iof.6.1551159634869;
        Mon, 25 Feb 2019 21:40:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551159634; cv=none;
        d=google.com; s=arc-20160816;
        b=kMspEWVh0ujwnwli3IJDryYuCO162SwEXE7x/YQNXCTjgG2GqiiKB/4Zna0wwAfm8I
         ygB3+0niovZRBhAg1+0lyVv1mp7hHnP2Sms6W0kMHHM+/WAbrSUpvNcu+Dn9pLxr0tNX
         79ykZ2ubuGBv+nSkkKzr2AiOUlR+iKscuVIazw876uBYgiKWKr3W5OXb/TRZJDoiXtFK
         bQ3rJu6uYligU0vbIiWdBf3mh/eGBuQB71fyKVntH+AzjZLQAPgKzZLEVi7Y29U4LCY5
         yoDZXHYRPma0qNYyLnawLJeUjdY6/CWymv7s5LPvIIMOnAj3PT8AJrdkfdaAJEl2DveC
         1eRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cwd5WKENydJd1AJ9VjYkBwcxB6cS9K+hKRcVy4TnBYU=;
        b=kqhx/Dq7WsmzVsKRElylLenk53jVuvefQpuswddGk+fbytOo6CSzUu8UG4rwN3vWMx
         NwS+HvdflwKZQLiu7CoMpH2CpL5W5g0ipQ2s1WaRz7VJKffys7/l1hL4C3R8paW+pcf3
         f2G6wzO0NUHGTePxOu1MUfVK4D3kNFFFEkfv5Yulf54C52Z46sOP7YmsFQXUkxI5UZOZ
         WIuByPBoR9zMrbmvhGyh7nDNh6/CKzAXcgKTMRdzi2/QFmcvBnMrfOj/5LHJIzwrfvOQ
         FhQsKkPj0usOLYuCIN5j2fl/5rtVKzw43Pw7qQgXVzzPIAP0Gx1dL5OY9Ivk2cC3dhfX
         OgeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UVfexhYQ;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c15sor5331083iob.79.2019.02.25.21.40.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 21:40:34 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UVfexhYQ;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cwd5WKENydJd1AJ9VjYkBwcxB6cS9K+hKRcVy4TnBYU=;
        b=UVfexhYQYVM7OO/Y6mGYyay7LIdXpdQbFycFO/6vxeoEAvZvB0PdwjgdS5/GLM9nHT
         gHnpTnpCwMFjcDLFTmwm8JnV9XQgnO705Tic6cseoI9X7n/j3RivlqovvUMlevu4Z6DV
         r5zJ6ye632K24DjX46vpMQvwZBJHojz++ieGoD1Vhy1dRSx/QTwWkdVaHWWjseSgw2Ak
         PfN9YNntFEKxQl2S2TYEvyZrAo74ab/ZzGZqrJJDvzqV8kxsHqsAX/FQAOttIP2p6kZA
         eF0sva3xL3qckbDUqfsn574Fc5gHl7kqYPJ7c+wwEp7gpSO1Fmah26n8P4yl7oEhDsaf
         gAog==
X-Google-Smtp-Source: AHgI3IY6QEwonoS6fzWDIUOgbIdEtgVosiEWIT3kvbZYdAztyEi/OEqMDw9i+umwpCh+ioT6Wru6jzIismwumcYfN7Y=
X-Received: by 2002:a6b:ca87:: with SMTP id a129mr10644882iog.281.1551159634696;
 Mon, 25 Feb 2019 21:40:34 -0800 (PST)
MIME-Version: 1.0
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
 <1551011649-30103-6-git-send-email-kernelfans@gmail.com> <0c76e937-7cca-12a5-0655-ea8c4a427c54@intel.com>
In-Reply-To: <0c76e937-7cca-12a5-0655-ea8c4a427c54@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 26 Feb 2019 13:40:23 +0800
Message-ID: <CAFgQCTuzhF+iGaH3rbw1C0Fb0dGdwrR5oXh+_jjuuPYhOankQw@mail.gmail.com>
Subject: Re: [PATCH 5/6] x86/numa: push forward the setup of node to cpumask map
To: Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andy Lutomirski <luto@kernel.org>, Andi Kleen <ak@linux.intel.com>, Petr Tesarik <ptesarik@suse.cz>, 
	Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Jonathan Corbet <corbet@lwn.net>, 
	Nicholas Piggin <npiggin@gmail.com>, Daniel Vacek <neelx@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 11:30 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 2/24/19 4:34 AM, Pingfan Liu wrote:
> > At present the node to cpumask map is set up until the secondary
> > cpu boot up. But it is too late for the purpose of building node fall back
> > list at early boot stage. Considering that init_cpu_to_node() already owns
> > cpu to node map, it is a good place to set up node to cpumask map too. So
> > do it by calling numa_add_cpu(cpu) in init_cpu_to_node().
>
> It sounds like you have carefully considered the ordering and
> dependencies here.  However, none of that consideration has made it into
> the code.
>
> Could you please add some comments to the new call-sites to explain why
> the *must* be where they are?

OK. How about: "building up node fallback list needs cpumask info, so
filling cpumask info here"
Thanks for your kindly review.

Regards,
Pingfan

