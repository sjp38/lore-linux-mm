Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 717A9C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:29:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2212820811
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:29:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2212820811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DB398E0003; Fri,  8 Mar 2019 06:29:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 861388E0002; Fri,  8 Mar 2019 06:29:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72A558E0003; Fri,  8 Mar 2019 06:29:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48F288E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 06:29:58 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id i4so11674495itb.1
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 03:29:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SajXQzW9X04+yPnaZqWHEKOB0mF5f8KwT4oltqr0ZBw=;
        b=mCH6+dAj65avPFv7pEM/klnugvcvml3/IIcrLKOEdAjZ70SQX9TMmaG72AHRZTG2Lm
         pjbsAwjmtZCDvP0B1INcpQfs7hxW9bPw7VX6JR2yc0IlBDqscmafPEcPfaveLR+qASNu
         FoU9vvGft3N34A1CpbimtHS5B6rAJicWCqBiz8v+8NH1ylufcw7IyW20i17FVYQS/Dml
         EUuJXOfwyT9ATMLAnkiaaTK85saZiFHp9HqQu3L5yXm8Jnw4hjcRupUBbqXP976h17Tn
         QGcHYaKNcfGQYuJLbHs+R8PUElIVA50SBMP0Bl1JSR+PJV9jxocTXSJA0XGtEDcF0gec
         ZJ9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXvoyZ3ZEBh17kENWVTSYSqo+TUppfJAH3Hbw58+GGRZ56W7eEa
	lozJCaCb0DezcZggWQ4uIM2gPjWH/CKhtnxRJqIn7xEvJeUe3QZvcDh4HLvNnVz33+DVWd8GaJn
	B6BDF/YWo1HgC3umMOxMQhWt0M4e3m9ShWAenz3lBZdiXaJRkJzZKvRFUt42n8J1ZvQ==
X-Received: by 2002:a24:10d0:: with SMTP id 199mr7182280ity.131.1552044598059;
        Fri, 08 Mar 2019 03:29:58 -0800 (PST)
X-Google-Smtp-Source: APXvYqw8GT9DQEnu2Tnz0O/YmJGAuxFm7Q+gbE6E05rrYvcGeABfhCXQzMImIyhy3UBf4bIkVbl7
X-Received: by 2002:a24:10d0:: with SMTP id 199mr7182248ity.131.1552044597139;
        Fri, 08 Mar 2019 03:29:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552044597; cv=none;
        d=google.com; s=arc-20160816;
        b=D+dtFKgLgI/MZebwclcI8eA36jEhJBeyjurX8ORJCKAO7PmHVe+28gUU2t6DmLI+T+
         wBhpSAGz4wfVm2+7O5GVqKUMBCwsglBhsmHvTiVRFbMscVX95iE9wgglMwHf4hTZDiet
         5Jsx7rrMSone0Vki2UOwnvowaai1gaZSxphBEZ798fG8INNjxhvkj5vhIPrf+RZQqwI/
         OV3kM6mvsy5XfVHu88q0f+3En9xtLcZomZbN6pgxKI7+Z2z9Ol8QvmlXr9PfEf2ubQII
         W0uP/b6NU/B6ZOGRN2fICXU88MSB/6MIUp7gz5iBBtaNcE1tE2oHiu7DfyzQfUFAl5N7
         dziQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SajXQzW9X04+yPnaZqWHEKOB0mF5f8KwT4oltqr0ZBw=;
        b=hY4jlTfNLuqQaOWzfgPVToglM880aX3WmWFyvppM+3vuGIj13jfkYvVCL85GzJkT1b
         YE9tXkdPzRCHaS302P3gaC3dvYqRBPbjApHCYupG89k6nOFTC/D4/EgA4hnhmE0NlW3a
         Gl+TuaRv3DI7tILnVuLNFqyZzk+BR1CwiPbWHQ+mS1YO29VodXBtjZmyE6OB9sHH0xCc
         0QMndoYXbwhFOASXdkiAIQbBzwYN+UnTuHzcd07aoFOiJvMuAwIzRyp8kQq0WTUGbhTY
         SGnXNP4hq9FxSlZQrDxq6zGvREs2yPag8MGcBWNcMHpd49cGu/2ZCgNnVgtWA/LDssEP
         Eg2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 84si3656907jam.112.2019.03.08.03.29.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 03:29:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav401.sakura.ne.jp (fsav401.sakura.ne.jp [133.242.250.100])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x28BTplf050362;
	Fri, 8 Mar 2019 20:29:51 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav401.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp);
 Fri, 08 Mar 2019 20:29:51 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x28BTjFe050310
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Fri, 8 Mar 2019 20:29:51 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
Date: Fri, 8 Mar 2019 20:29:46 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190308110325.GF5232@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/03/08 20:03, Michal Hocko wrote:
> On Fri 08-03-19 19:22:02, Tetsuo Handa wrote:
>> Since we are not allowed to depend on blocking memory allocations when
>> oom_lock is already held, teach lockdep to consider that blocking memory
>> allocations might wait for oom_lock at as early location as possible, and
>> teach lockdep to consider that oom_lock is held by mutex_lock() than by
>> mutex_trylock().
> 
> I do not understand this. It is quite likely that we will have multiple
> allocations hitting this path while somebody else might hold the oom
> lock.

The thread who succeeded to hold oom_lock must not involve blocking memory
allocations. It is explained in the comment before get_page_from_freelist().

> 
> What kind of problem does this actually want to prevent? Could you be
> more specific please?

e.g.

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3688,6 +3688,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
         * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
         * allocation which will never fail due to oom_lock already held.
         */
+       kfree(kmalloc(PAGE_SIZE, GFP_NOIO));
        page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
                                      ~__GFP_DIRECT_RECLAIM, order,
                                      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);


Since https://lore.kernel.org/lkml/20190308013134.GB4063@jagdpanzerIV/T/#u made me
worry that we might by error introduce such dependency in near future, I propose
this change as a proactive protection.

