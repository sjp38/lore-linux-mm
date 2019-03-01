Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18B35C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF1672083E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:49:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF1672083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BDA18E0003; Fri,  1 Mar 2019 06:49:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 641768E0001; Fri,  1 Mar 2019 06:49:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E3508E0003; Fri,  1 Mar 2019 06:49:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5AA38E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 06:49:55 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m25so6088043edd.6
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 03:49:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jRMAPHoukGK1ZiEIVH7ngseYQSNhVF4BN3HDV1TimDY=;
        b=ZsqCOzE3BXCuN6PY9njNpmw5TQBsUoS3e+1QM06/9wqLi9DrsFRx/+9g88OvKua1ME
         JKxQRscMEdTwtqZh7EhL0XHQeUheTuSb5V82/54XereorSfbCpm0GEoiYlqwtqmkmCSk
         dEC1UAnrdGYY4Hc78vGTkHEawhboMnnjTU4OqcPjACgwPNmlRtCjPvExBqpHdIRA5G/X
         wo8hYq1ttw7oHkKGRbn9MsAcFPgH3/JNhpCa8SwNHkD2p9abRzab8VUOHv02RiSbXSnW
         aNRcGaYSqmwgSqTulNJFrT5nVEk0VjuMoFs4fb/hmQ92IUrMplCYV+774NcC8185JXCL
         SKwA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVVH+NtS7e7AJc0qDjE05DtBVUwq+1j1rTRYvyEBIPrOYGlOvJY
	jSlLTSEE5kRXVZacCq+OrrwLSvneZ4VWbufp1HM5qLMEpJKhEOrO6y3QcfDG2bLbSxOtoqEtTxJ
	MDHygqSskdOfZRCmdGKEHP9htrP3vvUAft04T9d4IV7AHqodj9iX2CDhnPcfS2+0=
X-Received: by 2002:a50:b1d8:: with SMTP id n24mr3781823edd.137.1551440995430;
        Fri, 01 Mar 2019 03:49:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqwsYe4fGCuqmFscUvpwSvrJkw8IuDgLhyWrTcOtzSRJH/JCi11oC4OY3lB0ScwDcLnYW0Xs
X-Received: by 2002:a50:b1d8:: with SMTP id n24mr3781765edd.137.1551440994466;
        Fri, 01 Mar 2019 03:49:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551440994; cv=none;
        d=google.com; s=arc-20160816;
        b=hu50OVgn8t1D2zeZUK3vFxzIUms0yH3RF3Q9VnRSx/Gb/XzzR5cp01spTSoPHvt4F9
         +vaRAV0AJlkcgD3qdU3TE4kH3ICm60M73zcsTADwXG2TJbBLI6HX0/EWdxOynIH/VgeI
         0G7xVGC4Zrmywtegl8Rihrze818jJNP5dgXfsAKOqvv04/NPgiTNCPHEjZwNlefqHFrA
         URw/6fQfDQUX1QuXtNBJrmSI2V16wFA+PueRJsn85tuRY32qMfGdMOoR/ko1Aa3uUmJj
         3omZebSANXnZsoqHIJLUV/cJHS0Dkf9oaYnnUmH6t6PixoPzIGd2cfOFKF8JMyktndqK
         dFWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jRMAPHoukGK1ZiEIVH7ngseYQSNhVF4BN3HDV1TimDY=;
        b=lt815KUeqwPVJd4X7YiwJI7vzmrdqFkvFRvq1mZ/LSJlYHsa74tc42sGze3LDvp6wK
         Fzwscx/iC+csyQd5bQA3j2CnS9xIJknoTId3gKnlOO4XmuYJIILxuiX9Mth7xJkeLtuG
         lpV81TBefCBm4iCPxooE6VEyp5dLf8oAZZfDKu1CT7DF3a0WSmh4VMOUcyIG/f7lmFDx
         ho8/gQ961cFeraZW3rKvWsnzn/aEy69xJGOfXzoatOwsYMwjc2nm+wah9bUpPT2P6Gdg
         gqonDcNPGFV7rjhkxIY19T9CHlhRe5gWR1G3Xcs30nTYgFq6UBGR5kgl3FTeG43CzX7q
         ejPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e53si2782580eda.71.2019.03.01.03.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 03:49:54 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A7427AFC0;
	Fri,  1 Mar 2019 11:49:53 +0000 (UTC)
Date: Fri, 1 Mar 2019 12:49:47 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org
Subject: Re: mm: Can we bail out p?d_alloc() loops upon SIGKILL?
Message-ID: <20190301114947.GH10588@dhcp22.suse.cz>
References: <201902270343.x1R3hpZl029621@www262.sakura.ne.jp>
 <20190227092136.GM10588@dhcp22.suse.cz>
 <ccd9e864-0e47-b0e3-8d0e-9431937b604c@i-love.sakura.ne.jp>
 <20190228092641.GW10588@dhcp22.suse.cz>
 <f64326a8-092d-0d13-3795-4d01d242379c@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f64326a8-092d-0d13-3795-4d01d242379c@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 01-03-19 19:30:54, Tetsuo Handa wrote:
> On 2019/02/28 18:26, Michal Hocko wrote:
> > We cannot do anything about the preemption so that is moot. ALLOC_OOM
> > reserve is limited so the failure should happen sooner or later. But
> 
> The problem is that preemption can slowdown ALLOC_OOM allocations (at e.g.
> cond_resched() from direct reclaim path). Since concurrently allocating
> threads can consume CPU time, the OOM reaper can fail to wait for the OOM
> victim to complete (or fail) ALLOC_OOM allocations.

But this is an inherent problem and we cannot do anything about it
except for increasing the time the reaper keeps retrying.

> > I would be OK to check for fatal_signal_pending once per pmd or so if
> > that helps and it doesn't add a noticeable overhead.
> 
> Another option is to scatter __GFP_NOMEMALLOC to allocations which might
> be used from fork() path.

This is not really maintainable. Page table allocations are used for
other purposes as well, not to mention that each arch would have to do
the same. Why don't you simply try the fatal_signal_panding per pmd for
starter. Then we can tune the retry cound for the oom reaper.
-- 
Michal Hocko
SUSE Labs

