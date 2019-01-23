Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68253C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 22:57:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E938218AD
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 22:57:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0epgLqX9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E938218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F6A78E005D; Wed, 23 Jan 2019 17:57:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A73B8E0047; Wed, 23 Jan 2019 17:57:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 583768E005D; Wed, 23 Jan 2019 17:57:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 270998E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:57:49 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so2917180pfj.3
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:57:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:subject:in-reply-to:references:message-id;
        bh=eJ2UE7TMVX07gqbzPGgBnbf4NCCDIH3t0TlJkTzD02M=;
        b=n09GS4HrVKI+dVfzvPZt6BKMqNcu5oQtTB1imv0e3V50JZQi/0FY8BbUsfZK5Lng2F
         FVKa7fpcWu5XAgDvku2ytcHe+cgnPUO8NGjzYLEVEmXBURJ9Rf+aQdjqji//KdmyfVky
         hw9nSgOwGwQ+8HNKHdWaucCAFapiTi+adhncS5uIb421AXfamLVumvqUialRPNgxkjfI
         tt3a0PZXBRiV5KbDE5Va3dujx3iQc8Uy6slLVFHOgtU+2Os/EG05Tk103Q9nBEl9r16d
         KEQ7eJ2AdduJRzG/J0XzhscXkeJy8YdS412KLypjg6/4G7KUN7hO372o6PQk9is8pLoX
         jg7Q==
X-Gm-Message-State: AJcUukc7GzQlp2sanjWPH82HnEWfe8o4s3fKZVoCyvXCyGSXWsYOgPA9
	5Il0LSfgHwiivP6sWLr7rPsJaFhpjhICNvkvwLUkSHl13RaXkd/1YnORaVe1feIncmcXkt+xCug
	1OrL7wmK0HRQxbnLD7DUl51P1XLxvulG3ETA8vVCL2HQsVhN1w4ppWjWiKWr2h7nvAA==
X-Received: by 2002:a17:902:d891:: with SMTP id b17mr4236356plz.80.1548284268790;
        Wed, 23 Jan 2019 14:57:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4+q2XtgJXJYO73pALBPi0qfjij7x/eBd8rTlDEfQ1JMSji1MY3Wmk6k4RJPgEtUPsIFXIo
X-Received: by 2002:a17:902:d891:: with SMTP id b17mr4236336plz.80.1548284268077;
        Wed, 23 Jan 2019 14:57:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548284268; cv=none;
        d=google.com; s=arc-20160816;
        b=KYQVuvbYsY+T3Eu2EM0bThD6N/81K03tHqiYiebmjTO+YIsLlnZ23dqMC0g/ZNot7J
         wVUwNUu7tOjLmMNda2mxEU4k4ZX00kC7ozZWjCuYzoXomxiso3J8+wAGrX3QObtFvPc6
         8b6Fx2pAS7JiQeKlfYJ8Q2ay06dKkzbv/p7NvwyDAES0YxtfVqqBniSYDPAx1tAqt72e
         ywrcRtYXgPmL87Tdk6gMEi0XMnQdmtR9cuF0lKp1jZcl8VHXA/Yj872IYB7KZFVdXRwU
         ZMQDcXuUaEFQFyamXC10fJvxYSrdSjBcqbzAzD8Px+au/b7NsJK04hQLrXRN4RvbXHwE
         qC1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:cc
         :cc:to:to:to:from:date:dkim-signature;
        bh=eJ2UE7TMVX07gqbzPGgBnbf4NCCDIH3t0TlJkTzD02M=;
        b=G2gqpVl311UfcKp8BT7tkKzam3BDeLk+BaI1I9lv6kyy+uWZwuF3nZNpMtYlI9Kls+
         oUi8PV0AZub0FyZy+A8bz5JjwTigTlLGgdvZig3ecXetgs5fqZDXtnz6cXHgt4AhmGRY
         Q+nc2V/947bR46dBFwYScbvAz9dEGZZu3hd8SfMdqWUY++VwgbD2fjpgBnrKFibbXVl2
         3SwyMRw7uQ4kChlSfUYd7SYRdgstKuepdqaU/Kt08OSequgK+YvQ14VZTUCdFqx0bVqC
         N2jFbuwObCLPJmZCh4WDs+I9/0jZYhTKdBlwGZlScj6hX0LHfODko4b9cYhwkmYlbviP
         6/4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0epgLqX9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x74si8303366pfe.23.2019.01.23.14.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 14:57:48 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0epgLqX9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8715120856;
	Wed, 23 Jan 2019 22:57:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548284267;
	bh=oLNS/nrnztPm1VAepN8hd9okW6w7EfKR11vWYHLQuUg=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:In-Reply-To:
	 References:From;
	b=0epgLqX9XWIjQPs9OkvZWSnPpOKZJgsOnY6EJNwpLUugRbNAsfJ1QpzXIPInOfKR9
	 1g1uEZtMCeJu9W8kdeYqNCOU1Yb02bxwAm5utKz6dztolXYh+lk7Xp12RcWJxWIB0e
	 U9pM8ZLIKoO4r6zrOMsBuZ1aJQjl3kyJY2Lp4/EU=
Date: Wed, 23 Jan 2019 22:57:46 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Shakeel Butt <shakeelb@google.com>
To:     Johannes Weiner <hannes@cmpxchg.org>,
Cc:     linux-mm@kvack.org, linux-kernel@vger.kernel.org,
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: stable@kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v3 1/2] mm, oom: fix use-after-free in oom_kill_process
In-Reply-To: <20190121215850.221745-1-shakeelb@google.com>
References: <20190121215850.221745-1-shakeelb@google.com>
Message-Id: <20190123225747.8715120856@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190123225746.DWVZuAQLmJ4oJWIT4RgybPOEd0E2UBXwSZop9Q5kg6E@z>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 6b0c81b3be11 mm, oom: reduce dependency on tasklist_lock.

The bot has tested the following trees: v4.20.3, v4.19.16, v4.14.94, v4.9.151, v4.4.171, v3.18.132.

v4.20.3: Build OK!
v4.19.16: Build OK!
v4.14.94: Failed to apply! Possible dependencies:
    5989ad7b5ede ("mm, oom: refactor oom_kill_process()")

v4.9.151: Build OK!
v4.4.171: Build OK!
v3.18.132: Build OK!


How should we proceed with this patch?

--
Thanks,
Sasha

