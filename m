Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB47BC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:26:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C20420679
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:26:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C20420679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0841E6B0003; Tue, 18 Jun 2019 09:26:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 035008E0002; Tue, 18 Jun 2019 09:26:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E65B58E0001; Tue, 18 Jun 2019 09:26:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8A576B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:26:51 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id m26so16178175ioh.17
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:26:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gtZEafr2AdSgWF2NfvZRKJy23ry0AvbRcKXbNreAn8Q=;
        b=OYkywvTKcFBBuUaW+BWYQnY9TUES0x66SVM/EL2EDE+ifsiT/JbVUlNbg6SHEji0Sf
         yKIJmRk3TWSEb7FJBB13rA68imTwFfnmnCsVPW4svBdTCZ3342+8uZwFU+H1JzZxA8ES
         TEIHlE93Oa1ULZYbyGWR1S4LAPFckt22LIYynG7a+/TX+DBU3Tu7oshXyJWiEvN79HRR
         y8E0Saroum9ZBfExaUmuethyjKBRvr6vPHVxcLcoN5IBFrI06WGvY7P4pReOMNNk9qUe
         diF2QcNbrLzBdS44NB7U2g0huar/Qqpp0JoFstCmc68GMi3hJB9eJT0IxbJXRKLcyg5e
         hsdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAV+258F+a7HyD5brJPZNnyzhw5mCWoxTzHrNESRsFlpnOhfe4xI
	2dHVDV4XrKIdxFmaAJHsmT98FyXvEBO/whqJeDJUkf/LUoEXFEO/DvbqEWf7G4bYjFudtDG6S4u
	atWpNod9cATMIXcyK7e78FpNa/xlkc67vB6uHdZJ/JFGyut/QszWsul4QRAa9Z446VQ==
X-Received: by 2002:a02:c952:: with SMTP id u18mr65274780jao.23.1560864411544;
        Tue, 18 Jun 2019 06:26:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCYP+vnMT8MvLZUG7PAXeQ3pqeHKWNxBVOrD/w8JvogkD2EFd+8Gk4IMlwOEgBbtnnuROt
X-Received: by 2002:a02:c952:: with SMTP id u18mr65274469jao.23.1560864408822;
        Tue, 18 Jun 2019 06:26:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560864408; cv=none;
        d=google.com; s=arc-20160816;
        b=uLY9JX2nRpCR5aqOdWM9Xz1QnZA5XaniJ05xRkPdry+PIdRSMqvA6fazsoubThmbDu
         6o2+DbIztijloxFKWwHJ1FzOHBTDm1MLSldMMbSa6jIJ7Ql0/H77kG5nhDWUhCS++TO/
         E9IE4hZ+S+ifI2qqCJTUa/vahB/1+v/IXjlRd8u5JevXT9TJcEM9JVUDumTNEG++tKFB
         qBiXD8MjVxJbJzWtnFkK3/oxbnS3PUUJNQdN7J37tAjrHOEUB9kqXzj/5BmWTMjy9BRC
         A5DJ2b/BcvT0WHeAwCs8KyI7qRleE7RMhmkA4q1JQ5n23swBmfeBejYsH0RL8gnKjOZT
         9LPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gtZEafr2AdSgWF2NfvZRKJy23ry0AvbRcKXbNreAn8Q=;
        b=1KcqOLnd8ewf/1ire1TJOceu79KKDw51ZA8qo9N9Sw/A/Vb/D+gzzBPYO4wDNJPXp/
         d4Denq8ict6O07t12//f1UGQNaPlzUpAmVEKmL8GuU+xWSeCEB/gIdyoT/jhBpVl7hKX
         KmTBp8gtKSFnTssrtwu8M/C8rH+vcR9yJ+1AjuPNCg785ay57YxTcttuPygY31gjnYv6
         k6+ezDMJ196NmcLH/dlICk54NkuPAuBTRYTY7a6RTICBR0QpimOX9DIXAvW5srTdgPEx
         V7uhjfPN/WhECwPwUQFjiX2kTg4jAv4Lbox1MwuV28JCuhR/cEbiV5peBIyZ/EKKrfCE
         QaQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o24si23918796jam.31.2019.06.18.06.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 06:26:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav101.sakura.ne.jp (fsav101.sakura.ne.jp [27.133.134.228])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5IDQdOA034300;
	Tue, 18 Jun 2019 22:26:39 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav101.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav101.sakura.ne.jp);
 Tue, 18 Jun 2019 22:26:39 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav101.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5IDQcQt034291
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 18 Jun 2019 22:26:39 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm: memcontrol: Remove task_in_mem_cgroup().
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        David Rientjes <rientjes@google.com>,
        Shakeel Butt <shakeelb@google.com>
References: <1560852154-14218-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190618123639.GF3318@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <2d3e332f-9048-7711-ba4e-b8bf517194a0@i-love.sakura.ne.jp>
Date: Tue, 18 Jun 2019 22:26:35 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190618123639.GF3318@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/06/18 21:36, Michal Hocko wrote:
> On Tue 18-06-19 19:02:34, Tetsuo Handa wrote:
>> oom_unkillable_task() no longer calls task_in_mem_cgroup().
> 
> This was indeed the last caller of this function which got me surprised.
> Let's fold this into the refactoring patch.
> 
> Thanks!

OK. Please fold into "mm, oom: fix oom_unkillable_task for memcg OOMs".

