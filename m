Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 932D5C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 13:37:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3716A2085B
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 13:37:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="F/mOMAUL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3716A2085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2C0F8E0002; Thu, 31 Jan 2019 08:37:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DB388E0001; Thu, 31 Jan 2019 08:37:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CAF08E0002; Thu, 31 Jan 2019 08:37:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6605C8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:37:50 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id b16so3483565qtc.22
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:37:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+J49GTNqrH+Q1rNhdO2ofcioHRQbNfNckDiiZO62Q8E=;
        b=oTLob1so3Wv3oZcvuRe+CrP64zs3CNAFi93AuoNz0/I+Qy6Yfr8tIOKuM2XKB8T3AJ
         NlyMSbmeMUa6yd6lBRyEh6R8dHUfMr/qwdqctcZ/sYzIsGlAhYFBVD+T+twGmYGn883L
         nYidKIHVsnL3jiHE5DbvHJmtT9+/p5kHwKZjaVRbALI9IIR4KrEmT3sL/hNNmchQ/7Qb
         haVmsbNwSUAc7eksXUXoJtgsMyjrULxgrDWxYrAQl0hKvIz+Wv9BQgHva+1m72eUnZO0
         sYBaRMKwNUdVtYxxrD2VsrN4esqY5vZbqPj2PGlK8JTfYarW+logXkbm8hWrawZgUjZO
         m4XA==
X-Gm-Message-State: AJcUukd1rZz7D9A7nNTn2QMVyCc9u0iQjX4/umz+tUxsGiD2ADep9N7p
	nlm1a1U+FqCmMLZ0CZxVU/cRi0l+tMZIuy406tX7bdueGObwZQB+BitCCx/+PZ0GSNZh9meFvOh
	WOKIW3AbgkIZ93fHI7uaS7cS5Hv2Ma4aRAPIc5dUQL/5x8yIyU8AVasc3cFpCLPPF5Sn0NnNeIp
	O3VKe1M7nYjALc+9nLq4Y/o8m4eZ8v5nAIUkfzeut1Cfllcui4Za/rndATTGAneQpovDOB47YIt
	uy1vpCaF3xXX2dD4ZRC5YD0G5yjdFHNlZHQzy1mq315cP+EqgR//x6ZB7Qysyn6mFkWrW/qWS+d
	5C8tR4CCAlQEeI+wEvl5KgzeANvAZO01c7oj4+7AyT7+Hsugj5kdY2XeSeCevTKp3GIjH34kAxk
	J
X-Received: by 2002:a37:c51b:: with SMTP id p27mr30038890qki.86.1548941870132;
        Thu, 31 Jan 2019 05:37:50 -0800 (PST)
X-Received: by 2002:a37:c51b:: with SMTP id p27mr30038857qki.86.1548941869618;
        Thu, 31 Jan 2019 05:37:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548941869; cv=none;
        d=google.com; s=arc-20160816;
        b=g0TZsTo+CQASyEJ+tpT1JOXYPWlJSJxfELMTzLlcfKPrTcZz8pGytcjZfKZwqEKrAH
         ggaaxOZ4QCeCvhQAgtyQMvkmaN9BrV+aozpsDdTPuYCzknYwBQbuQK6jo/XCRDiy3KIr
         RFHdCqWrCD0L9U13DhgDp5W15XlBoQfWnhYqBluMQ2FdgGMjrdn6oYy1VU/VQMRWkwRA
         RB5Pl+BdPziloOuKRWBRPH52r+74+nRGwuHwU8MuoL3crltxDl/3UbtVA+dFK0WDCHAo
         JF1Xuh6svQ1IUATOWCKkGKQmLbRsJJfG/AY9voHnQOrV89LAvGydzk8YSZTlwuQkvWyo
         ftRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+J49GTNqrH+Q1rNhdO2ofcioHRQbNfNckDiiZO62Q8E=;
        b=AmBAjWzwC2GHjwYMbHflsvZI2ZD/vBhFnkqx2TsJGm5mZwx34sBOuYYVoxdpZRSjWK
         MNf+TIyNjKWE089YEk87QtSifimio6xDQwbOUIHwIP3jly/RLdBhMuqy4s/i+Q6pVXM0
         EdfP3i5aBsU0Tx9X3wvm2WIpvzQUxP7T38hOq9232sKoApXk25dcEBOeAM5ZhaZZah03
         lHG3hVJ1ApnAV0w2DqcuzyPcXNL7DuqWAR/gBQgQlJDA+/onqzcMyPQ8G7p2qodIkloZ
         N+ZiudjgAP4FwFzsVxQ05ha2xQGB0URfFQ6VMY59UOYMm013A3E7dFtjOd7BOWFsGOJj
         iVrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b="F/mOMAUL";
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j42sor710027qta.38.2019.01.31.05.37.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 05:37:49 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b="F/mOMAUL";
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.41 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+J49GTNqrH+Q1rNhdO2ofcioHRQbNfNckDiiZO62Q8E=;
        b=F/mOMAULxU5LCdlH4w3ZM71drEKq8nJjpaQGkXRFOlo3AkapiiXd9fqxLaCMzfX9Po
         3/hHsP1meFkb2Y1pvWkmcCe63xJsf1ILTnhu7Hq++A59q7pDkX9bu1yieJGMk8k7ZheE
         ij6H9VZ0oEStmRlG1f8RPFBRId9+G0iptEn7U=
X-Google-Smtp-Source: ALg8bN5XRVQnIvE58lv0fww2i4DLDSQ9mT1TSN7gG5Q1fdpfbc2iC8pnHzYf3OV9/dhURjjBhvWmuQ==
X-Received: by 2002:ac8:7181:: with SMTP id w1mr34340796qto.271.1548941868971;
        Thu, 31 Jan 2019 05:37:48 -0800 (PST)
Received: from localhost (rrcs-108-176-24-99.nyc.biz.rr.com. [108.176.24.99])
        by smtp.gmail.com with ESMTPSA id x41sm5671444qth.92.2019.01.31.05.37.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 05:37:48 -0800 (PST)
Date: Thu, 31 Jan 2019 08:37:48 -0500
From: Chris Down <chris@chrisdown.name>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 203/305] mm/memcontrol.c:5629:52: error:
 'THP_FAULT_ALLOC' undeclared
Message-ID: <20190131133748.GA28484@chrisdown.name>
References: <201901312116.bwXU2Jyz%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <201901312116.bwXU2Jyz%fengguang.wu@intel.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kbuild test robot writes:
>   mm/memcontrol.c: In function 'memory_stat_show':
>>> mm/memcontrol.c:5629:52: error: 'THP_FAULT_ALLOC' undeclared (first use in this function)
>     seq_printf(m, "thp_fault_alloc %lu\n", acc.events[THP_FAULT_ALLOC]);
>                                                       ^
>   mm/memcontrol.c:5629:52: note: each undeclared identifier is reported only once for each function it appears in
>>> mm/memcontrol.c:5631:17: error: 'THP_COLLAPSE_ALLOC' undeclared (first use in this function)
>         acc.events[THP_COLLAPSE_ALLOC]);

Oh, right. Now that we don't define these for ourselves in memcontrol.h any 
more and just use the VM definitions, they also need to go in an #ifdef.

Apologies for the noise, I'll add a fixup to guard these in a bit.

