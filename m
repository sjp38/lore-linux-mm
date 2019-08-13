Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E129C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:37:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11DD42085A
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:37:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="woBLh51W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11DD42085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC4566B0005; Tue, 13 Aug 2019 11:37:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A75AA6B0006; Tue, 13 Aug 2019 11:37:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93E666B0007; Tue, 13 Aug 2019 11:37:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0097.hostedemail.com [216.40.44.97])
	by kanga.kvack.org (Postfix) with ESMTP id 734386B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:37:03 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 29C936105
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:37:03 +0000 (UTC)
X-FDA: 75817807926.21.pin23_5a99956973f21
X-HE-Tag: pin23_5a99956973f21
X-Filterd-Recvd-Size: 5547
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:37:02 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id 196so4648048pfz.8
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:37:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lz+5UlOi1qxxGBIgahg/9X3yobOn5+akM80wHeA6n1k=;
        b=woBLh51WQ/ct5Mau6CtW3e2fv+4gutMwYr5IF6AzhtA/gRawkgJVjfj3lL2I9cQW6b
         oV9ghFkUDHHT6gzkNQmXvvL9gPL9RVP9dcZDUbOj0dMRylXq5DiVTQ3Oa5e6dut3Fj5v
         HUodcSNN8oxsllcQZnMdwLzV7Fzr/EGmVES7M=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=lz+5UlOi1qxxGBIgahg/9X3yobOn5+akM80wHeA6n1k=;
        b=UFb2qKdyCm5C9dj5BCS2gTYFK/HY7S0TwOrnT7tRGeH5Uk+VwpReKtbB1sw7YqtZWN
         I/ptR011t9Kx6sAnyX4OsvdFC+Lm+4vl3gO2Lb86IBLOdtGott7o/RbpF2TY0iCaUz7z
         C0SQPDuvHyL6AHgJcJq8WBxKrdydmmsxN9LckJ6Hcyl7yr3KEJte+Uz+PZErAeaOqthS
         NpB6SJYIbhtiu4jkvD8Xj58kauOsIaioaCT7Vb7OUhvemcTMDe97fhZRpveKWM7hknx8
         8BiUcaBUeBr5YqLt1CtNjmFsaSyusPuq8jfxVcFmLaUamVUmbIMQf/+rEZ7X5JumW8Ky
         liLw==
X-Gm-Message-State: APjAAAWEWBZTAyVD5GiqgBAv0HAhOHVpFAy2HPH5j3ahlcb8arQbmWIU
	b3Kzct45Dd03dswEGrOrSXCqXA==
X-Google-Smtp-Source: APXvYqwI65ttP97pW8RMlWdF32CvIfYXb4EMrQUFfUK/y0oRINDva/d4Zii5+wrMV6aDl9WtJzxUgA==
X-Received: by 2002:a62:f24b:: with SMTP id y11mr16086693pfl.0.1565710621336;
        Tue, 13 Aug 2019 08:37:01 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id 124sm113820431pfw.142.2019.08.13.08.37.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Aug 2019 08:37:00 -0700 (PDT)
Date: Tue, 13 Aug 2019 11:36:59 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>, khlebnikov@yandex-team.ru
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com,
	paulmck@linux.ibm.com, Robin Murphy <robin.murphy@arm.com>,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v5 2/6] mm/page_idle: Add support for handling swapped
 PG_Idle pages
Message-ID: <20190813153659.GD14622@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <20190807171559.182301-2-joel@joelfernandes.org>
 <20190813150450.GN17933@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813150450.GN17933@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 05:04:50PM +0200, Michal Hocko wrote:
> On Wed 07-08-19 13:15:55, Joel Fernandes (Google) wrote:
> > Idle page tracking currently does not work well in the following
> > scenario:
> >  1. mark page-A idle which was present at that time.
> >  2. run workload
> >  3. page-A is not touched by workload
> >  4. *sudden* memory pressure happen so finally page A is finally swapped out
> >  5. now see the page A - it appears as if it was accessed (pte unmapped
> >     so idle bit not set in output) - but it's incorrect.
> > 
> > To fix this, we store the idle information into a new idle bit of the
> > swap PTE during swapping of anonymous pages.
> >
> > Also in the future, madvise extensions will allow a system process
> > manager (like Android's ActivityManager) to swap pages out of a process
> > that it knows will be cold. To an external process like a heap profiler
> > that is doing idle tracking on another process, this procedure will
> > interfere with the idle page tracking similar to the above steps.
> 
> This could be solved by checking the !present/swapped out pages
> right? Whoever decided to put the page out to the swap just made it
> idle effectively.  So the monitor can make some educated guess for
> tracking. If that is fundamentally not possible then please describe
> why.

But the monitoring process (profiler) does not have control over the 'whoever
made it effectively idle' process.

As you said it will be a guess, it will not be accurate.

I am curious what is your concern with using a bit in the swap PTE?

(Adding Konstantin as well since we may be interested in this, since we also
suggested this idea).

thanks,

 - Joel


