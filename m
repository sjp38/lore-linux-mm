Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF6BDC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:39:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACBC02186A
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 16:39:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACBC02186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45D186B000C; Fri, 19 Jul 2019 12:39:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40C986B000D; Fri, 19 Jul 2019 12:39:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FDE98E0003; Fri, 19 Jul 2019 12:39:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA7006B000C
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:39:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so22400507eds.14
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 09:39:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5EaHXGuJMjh+887xI3sY026uNAnaO8i0Ga0Wfac/FRc=;
        b=IIUr5QxuLMgC4EkTmc8TvQdpX75YdWjefu6VPbaG+wOR6b02VTU9CwJHvJw27w4xsK
         FiyY55x9EwIvaJkVjN29CNphVZltHvoVjNfuorRjxQR2iO38Ky92kmlGxbYXH9/husQO
         qkuD87lqzAB+EtI5buO+9ibTLcNIfd2bfAIgRCe8xPK+PmAdwqOzShpujtY/7nIunORR
         mBaS7B3fSmuKrpPYr/Jk+GOLUBj7BRzglfBP/L4dRCllBMcz4RikjG4khRzcDmEwMOAb
         KCPv2aG+eHdO0Qxw/k3f+9p+iqyITd0MqrZU62SBqmRy0f3oN+2xsB61xvm7TZRTXPsI
         9T2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAUBF0/KAn9VpGL89E3sm4UIhmpLLVouR38EOEw5P3b3qfwzbNJg
	7AeBF/n9zGCPhCw9EVrBO7dls7orL+vzseCl+ImknRvdm87ewak30IRDhc6ctbCpNie1ncKXCJf
	2efj0Wv2XD5Lumts1EU10/4MUDWn9McD2XTqSzdm606f+r2BMF8fu8wMuUdwClVNiIQ==
X-Received: by 2002:a50:922a:: with SMTP id i39mr47197986eda.219.1563554379535;
        Fri, 19 Jul 2019 09:39:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbt099fEupYAyV8OrM+rq0EkAhBzrLbQtW0/4vwY84A1GqphWAk/p1afyrT28rA9QqSW/0
X-Received: by 2002:a50:922a:: with SMTP id i39mr47197934eda.219.1563554378889;
        Fri, 19 Jul 2019 09:39:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563554378; cv=none;
        d=google.com; s=arc-20160816;
        b=Ja6WQx+GUA/lk0SBh0xzPViGZRcNsFdjXauJKyVIMn8AE5DCmmWmJUky2R1zPRRm/b
         VohrjKyaOgsZOqwqUXpmyo3I7lYfNJ4c4yBahEn8SBu1V7fAMwXXhGkz2LF8M9sVlpVr
         d4GidCjMaD/WAy+WXw+vELPwsBSLxfJrHZ50XTxxgFuOop9OyV2liJGF13A89c0kaEGK
         9VisgIRSbQN5p7gpYSFw7X9y+F5vEMioFFuodnIwYy2wvatoNTy4YGxZIxGPvE6YpZV9
         NR2GVq/1gWCtOKIdkpwkJFLLzNzs3aMyRN0LjYQ361PhOxkhNBhhry2w5Y+fQUjT//UY
         Cczg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=5EaHXGuJMjh+887xI3sY026uNAnaO8i0Ga0Wfac/FRc=;
        b=CvqwRAFUpb8rCKDv7POkJGYjwpA5JHrk76E/b6T6B7Y03rvGQ0F8H9s8RddRqauOY1
         5wl/k0/oLatjL87irVfLuxU01fQ9LCfIEiEyGp2q1M5DrjLyy/3zPldd7ZLV1Ic6BweT
         7gJ++Styq0AuZiuhziVyPlvC2zYKCEis11NnL4A5dOlbCmIuw5UcgCeQuT0uIOv7CL2e
         ImXHPUBB+oJFH5xLuv/8bg9If37j1M8nb6+Z8qruPZCbbIqvh7R6gohXpWZ7WUIc6H6m
         rPXIY5Noi8aFHcd1dd4xzGf4yfPr6Yfq6+0ZcOT0WEwObze0Vd7qNgAiN8O3+WGmiSPs
         CixA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f22si548603eda.203.2019.07.19.09.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 09:39:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8D338AF9C;
	Fri, 19 Jul 2019 16:39:37 +0000 (UTC)
Date: Fri, 19 Jul 2019 18:39:31 +0200
From: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com,
	Peter Zijlstra <peterz@infradead.org>, mhocko@kernel.org,
	Ingo Molnar <mingo@redhat.com>, keescook@chromium.org,
	mcgrof@kernel.org, linux-mm@kvack.org,
	Hillf Danton <hdanton@sina.com>, cgroups@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 2/4] numa: append per-node execution time in
 cpu.numa_stat
Message-ID: <20190719163930.GA854@blackbody.suse.cz>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <65c1987f-bcce-2165-8c30-cf8cf3454591@linux.alibaba.com>
 <6973a1bf-88f2-b54e-726d-8b7d95d80197@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6973a1bf-88f2-b54e-726d-8b7d95d80197@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 11:40:35AM +0800, 王贇  <yun.wang@linux.alibaba.com> wrote:
> By doing 'cat /sys/fs/cgroup/cpu/CGROUP_PATH/cpu.numa_stat', we see new
> output line heading with 'exectime', like:
> 
>   exectime 311900 407166
What you present are times aggregated over CPUs in the NUMA nodes, this
seems a bit lossy interface. 

Despite you the aggregated information is sufficient for your
monitoring, I think it's worth providing the information with the
original granularity.

Note that cpuacct v1 controller used to report such percpu runtime
stats. The v2 implementation would rather build upon the rstat API.

Michal

