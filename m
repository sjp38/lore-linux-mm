Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C3E2C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 13:01:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7E4121A80
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 13:01:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7E4121A80
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 576488E0002; Fri, 15 Feb 2019 08:01:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FD6A8E0001; Fri, 15 Feb 2019 08:01:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C69E8E0002; Fri, 15 Feb 2019 08:01:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC8B28E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 08:01:49 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f17so3929390edt.20
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 05:01:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=odm1hIVqclAiABwaF2mlZE2RX6LUaeHa9OAe2TxCt18=;
        b=irhZ0GmmkkXYYdNbfMg/yQmZOXJ46KPo5mvjGONYAEhp8GeIpPqEG4cJbF9HcXjsug
         4K6pwqlxFWrgA1qa9T0ixbY/qhVtSiralkSMZk4ZQmukDDGD3tNrT4WN3oalcHYn/PON
         BsZEZ5WCGiuBaAKkYQM+5aZrmctY5UxCYilablqIYo+s5fuwV2d4i9EyCROt4knAoDw2
         k40uGvalXj3JCJDIOKj+ebgpVzEmgdyhGCZ4r6SA+2m9p7vnV1WUIoSTza2XMO4rzvIz
         ZPb4iaxUoywEv8roPNXuTRLiZ7kYk2IyOcaRBKU3fltNZJrCCen3W2WOFZ5WxtkLP0jH
         1Vyw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYguJE4jiLWUhkK7RbolTNOHQW0GYpiG0fvZdGNjqK7bjviaQ4A
	J96+Qd1a0vDtt7ZowaaCzp+/gCFgIyZWLC85xLS716jf34mCZ/gxboJITbtBWoBd/Ud57dX1HuL
	TkX0KYKDqEttASWn+r6pUNO9Hi5qdqLG+99eNM36YhmXC8Qjl1RG6rt0CUfOYPQo=
X-Received: by 2002:a50:b667:: with SMTP id c36mr7692224ede.190.1550235709477;
        Fri, 15 Feb 2019 05:01:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZFYmGsElsYrfpA2FE8TdVBy5/joJt1TN/QYmo+3mPXRYmVOXdLp0UhxpQ3m5JCOjbRLGho
X-Received: by 2002:a50:b667:: with SMTP id c36mr7692160ede.190.1550235708525;
        Fri, 15 Feb 2019 05:01:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550235708; cv=none;
        d=google.com; s=arc-20160816;
        b=xWALEoSCbxLOdV1AsxkLURjJWWlMT8ZEy1kx+u6wRi8LjWfba7Zs90zZl7fissIz6r
         DBiFgzB53W+FR26WrFHYnoajFKWNNfzJx9ptTPqUaSDi4rEyXRoN2rxi5IEuJVYHAxS3
         PuqVj09mWX6gOFNe/x+WXSQhaQBabBqQ3esY0L97iWyfVEjIzCIzA95KQNuc6uMAO7Er
         FgF00R7qvtnxggI1per+mJtrjykKvLboyK4DTGyPdxuft8ib7tDe39M1tJJRWNr2zkDJ
         vGEYs5Ic6tlZKlLlG6nGgOXq71ZL9AVTTSTiMUo6E68XhaQE+vQGETrGUyBsrbrsg65q
         e5Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=odm1hIVqclAiABwaF2mlZE2RX6LUaeHa9OAe2TxCt18=;
        b=ycbisw5eg3lnehel8MulP+qzGL0jYPPnsXmCmWvIHukmrrU9LAwliwE6ULfcV2KH+S
         IHiZhv7Qak6BRVSNbMS9nUGkjas4uafzwShv98EyGSkhV5NfSI9vsY71788EvroZVf3q
         EqLjzd9XlYblnbuzqfo4p5Ka16IOG0165w+DvImlZFxtuVChc9dvbODY3c66xpDQdG9O
         VCrBwzZEW0Upzxo6b8CsKc+wCO+zyv1+AUbZrowCNElFjBwf9h3aBr6L8p3LFlDDr7gq
         1zVOxnRkU3S2w8UPI2bXfiHWj02gARbmeugF7C5YXrermUQi/51f9vjxOyhgEi4vb9ms
         0PbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18si79805edh.385.2019.02.15.05.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 05:01:48 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ADDD3AD56;
	Fri, 15 Feb 2019 13:01:47 +0000 (UTC)
Date: Fri, 15 Feb 2019 14:01:47 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next-20190214] Free pages statistics is broken.
Message-ID: <20190215130147.GZ4525@dhcp22.suse.cz>
References: <201902150227.x1F2RBhh041762@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201902150227.x1F2RBhh041762@www262.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 15-02-19 11:27:10, Tetsuo Handa wrote:
> I noticed that amount of free memory reported by DMA: / DMA32: / Normal: fields are
> increasing over time. Since 5.0-rc6 is working correctly, some change in linux-next
> is causing this problem.

Just a shot into the dark. Could you try to disable the page allocator
randomization (page_alloc.shuffle kernel command line parameter)? Not
that I see any bug there but it is a recent change in the page allocator
I am aware of and it might have some anticipated side effects.
-- 
Michal Hocko
SUSE Labs

