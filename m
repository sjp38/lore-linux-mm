Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E9D6C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 19:16:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47E18218AF
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 19:16:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="W0Wn44AO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47E18218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAA2E8E0002; Fri,  1 Feb 2019 14:16:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5A9E8E0001; Fri,  1 Feb 2019 14:16:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C71898E0002; Fri,  1 Feb 2019 14:16:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9624E8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 14:16:40 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id v187so4773209ywv.15
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 11:16:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ik+nUeP1/vzq94Z7ZicHjBf1u7i2w1Mxdx/p4Q0QLSE=;
        b=WkiKFIhj+qE6gIHjSQRW8KH4au/jd2MX/usTti+UvpnN7ucL8YHmchTwqrUwyLEFrR
         0xucj9tRRNbeV8GT8SA00uFE4keUoicSzY1CB3TmShdvpEuesjnKstQ7UKzZ9EQ+AruT
         KhC+SLvdnDQBF/YIs9jirFk8YB06AFDn6MR16H+LX982uvtlsMRJE0y0ukb4xa+DJu/V
         QiSK2u0rrbGmlxQsE7pqeytIjVwasSOLk8OzmkWTGegfDeNrZAxeQ79xLtX0dbMFwgv7
         L/1OG+XxesJBczyzIGujRtJTa9BRvIEV6rjMu/i8B47CCECsP6fdiVmFsy5IkizO2mSB
         F8BQ==
X-Gm-Message-State: AJcUukfDAyJzxS+a0Hrj7WIK64UGOL4bswHW3JgixYr6osLAwbCvNy+/
	JmNT1YyC1UHJgLZAb35QaZnckqILpIN6HNJyAq3MLgk4Aev7dqnyKTlhSvCGuaIJtVpC9YBOUGJ
	WYXle6bdNjSH/v6LxxLaCGV4oZTBoFxC2xSsLaynfn9wTz2C+rbDZb3stIhLtcUIKwIIDDHDket
	AbhULu7RBoEO7rnTj0KpIpgFLKdohKOnYdQnU6+kLJ8lIOlRl0dUQNM0fM46FRgAp37i2Vk8vwu
	SYnTe/l0qqoC3WAbPR8A1aLmrP3ortvMwJIrB5n4DmlhEg5zKpGSA2UAzSAA8LmF4g4UniwDmKK
	vzzI/4HAdTRincdSsufb7F96QJqwNHUjC+uN/gG1m+KIXzlcCxzEzuOgiXaJbLis06wcmd2McUY
	P
X-Received: by 2002:a25:bfc5:: with SMTP id q5mr37458350ybm.86.1549048600226;
        Fri, 01 Feb 2019 11:16:40 -0800 (PST)
X-Received: by 2002:a25:bfc5:: with SMTP id q5mr37458309ybm.86.1549048599506;
        Fri, 01 Feb 2019 11:16:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549048599; cv=none;
        d=google.com; s=arc-20160816;
        b=lUvdkjll6WluSTvfc/oyvtpl8EOG2jNmxzaKaixJjTB4GZTpVBFVFtKq2fMNl4oDeO
         2Nf7a6je1Br3EXZFLdd+dhBbbdys7o6/MQL7JjKaDJLDIYdGoOinfm0D2afL0MOUsVkl
         7V2qfuERvSpG/zMHgi8PT6BnXej1AHw5AcrMXtnAMvKSK2ZDoFZvyYQZddKGwNaDQRz3
         I46h+XEb2QMWwW12HxtuPbhk/ZAXxVRgzikd+xelEZ4w359OIowIlAXsJam+zTG/Z7GD
         Hp9ZMBt9KjjWS+fw0YQnALHXqSzYaJJIrOuXZoWWxPy38lAu1xPTD9l4SIozmlOZ/XA5
         5J9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ik+nUeP1/vzq94Z7ZicHjBf1u7i2w1Mxdx/p4Q0QLSE=;
        b=wmjwI8ES7qgVR/earEqGm+BLDvTLPuFmePOMgO3zCAxRfEVKcexiK/1klAMNXqNy9u
         /byWjvwtcaVRxpqucQXQfMxHvXn3wWhZxLhXUO/xtBYGIqIaAEQ6RLQEbBkjokhcAR9d
         /jothhpdFHnO8lKXX36Eipl/ItoBo6V35wu9/WJKF3mr7uL35mRoWV6DBLf0qGprKIJc
         AHcij8XkTp8a7wQ5O9bDkh9Z23lTLLO9iit19Fe++CH0DfZDQvN+4JQGXiPcKEKTfruL
         274zjpdRw42T60vVustNc2dnJJ4Dhv2bHllM27rK3Cih8gTmr+Z0i9e7NEnCGGeIzGWc
         kRIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=W0Wn44AO;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11sor2669761yba.170.2019.02.01.11.16.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Feb 2019 11:16:39 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=W0Wn44AO;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ik+nUeP1/vzq94Z7ZicHjBf1u7i2w1Mxdx/p4Q0QLSE=;
        b=W0Wn44AOStTYe+dttllNOONJ0kwMX4EYLQZLRFhf29Z90hnoImF1lG8nSdMLxA0Qvx
         sKvki9e7iBsjP3b+VFMOseTyDlPyfjw7+rS04bf+5SjjcbF/W5qqz2jWs6AhKtXbfKiy
         eLeelp1K2HK81/hAXExiivV4njdyB6k3k+HJ0=
X-Google-Smtp-Source: ALg8bN7jsO17izO4IlN5zvWMlIrkEZZfYnh/+UYorNdvfS8QY9TFgotBLuVYeqKMWYHg+39wibJlWQ==
X-Received: by 2002:a25:e404:: with SMTP id b4mr38643858ybh.494.1549048598793;
        Fri, 01 Feb 2019 11:16:38 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:99ee])
        by smtp.gmail.com with ESMTPSA id l7sm3055420ywk.24.2019.02.01.11.16.38
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 01 Feb 2019 11:16:38 -0800 (PST)
Date: Fri, 1 Feb 2019 14:16:36 -0500
From: Chris Down <chris@chrisdown.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH] mm: Throttle allocators when failing reclaim over
 memory.high
Message-ID: <20190201191636.GA17391@chrisdown.name>
References: <20190201011352.GA14370@chrisdown.name>
 <20190201071757.GE11599@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190201071757.GE11599@dhcp22.suse.cz>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko writes:
>How does this play wit the actual OOM when the user expects oom to
>resolve the situation because the reclaim is futile and there is nothing
>reclaimable except for killing a process?

In addition to what Johannes said, this doesn't impede OOM in the case of 
global system starvation (eg. in the case that all major consumers of memory 
are allocator throttling). In that case nothing unusual will happen, since the 
task's state is TASK_KILLABLE rather than TASK_UNINTERRUPTIBLE, and we will 
exit out of mem_cgroup_handle_over_high as quickly as possible.

