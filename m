Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33CC5C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:46:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEBEF2075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:46:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEBEF2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F8B06B0003; Thu, 28 Mar 2019 18:46:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A7996B0006; Thu, 28 Mar 2019 18:46:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 296506B0007; Thu, 28 Mar 2019 18:46:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E73A06B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:46:05 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b11so66730pfo.15
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:46:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=9BvTe4MDDUohQzKvSWEOrLJ5MQ9S9B71FRrAUpw15qg=;
        b=buJE2x6vCtugIN5ajHab7MpKP3oc5yT1gMlK4GQ0VczrQzFG7O58EqCpejLUDwalus
         vuDdYcqp7aPoImMmdfhL8F7c2oc9c0wKmPJB3hlMWWcaUJ7B0bStefhgM72MyQgforF6
         GetPeRtObkb5Lxnx9Jqcs90H5fY/59t3sZlGDavg7NxElYnfz5jY6gI/6QAlKC73odBf
         70tYRJFB/KEwazkOJFOYMlPh9FIwTvRSuLpAgLa2yh5E3zYkAzJTikinzWn94g8/X0E0
         qSV3sYh1tbbdopKKKrGZrTmRZOuhlVFTQgHBvVPxb8bQWOqXPN0qhscvHOMOTzjtmsh7
         EkdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXvCg9Gb+ZnypsEhRlxBoAPR2sYItVABYyMrxk3FyHwe/IubV4n
	ZqS5fa3kN+YshTn0f7dBTdE5ERaGGWC1JfsLgpEkQjKsbc+I0tKt78NWyRrbcjrJez5YjZV1wYz
	rY//yV9VMgwBH5emXrPTrvv32p0wexb8zwgFYLXeFSK322JBCzYhEyQ30vNit9/rPbw==
X-Received: by 2002:a17:902:3a5:: with SMTP id d34mr43533578pld.174.1553813165644;
        Thu, 28 Mar 2019 15:46:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfXmqx19oJV/3Am4irs2Z1Bf/TdGGjKQKKrwvDjO017wcMOhdsZjpSMiAh150IdMtlJrFn
X-Received: by 2002:a17:902:3a5:: with SMTP id d34mr43533537pld.174.1553813164958;
        Thu, 28 Mar 2019 15:46:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553813164; cv=none;
        d=google.com; s=arc-20160816;
        b=NANiUrvdfRaAt/wfMnh4qz/SfcGyJd2frpQPug+TS/FDbx3GDLreXdPMhHO+WWY40h
         mDd23j+CBmlab/59kWl9TPt5mvIjHhC43YxGqZ5mP/cPFWhOXGnV/if183N+sN9QEaSc
         MBcVFnNOKACJP/NqIs6Laa6PRx2EdC2duPOmQ1M3yikwOu0LUpOHOqYERJJqa9sCRtDh
         XTYja03kQoqXtk7p50lHg8KMFJWhEMBYYMCiF//L/ZYoMr+NYBtzyWHEX1eCGvSggtk3
         pF+gfmOD2wZQBjV5gWFA3mL/AWQs6GxxZPq+fpkb9zvZpUrn6UBOvF1aQix2q8w6k6Ct
         Xxxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:cc:references:to:subject;
        bh=9BvTe4MDDUohQzKvSWEOrLJ5MQ9S9B71FRrAUpw15qg=;
        b=ghzjrDWu+wEcR092REcU2nSu7LAuYjMTtoD9lQiQPWzDXDOjx/gOxWny8f0ohBu8w+
         Lz//5GBhzCnGXlqiWT6cL4I0LFoz7QuzasfqCyC8FYyYnD8j8YXpnp94AlF+yxQ/uQ8s
         vCOyl6XbPkzxtomu6sHFhLciPTk88qaredt53NYN5HiXuvNWMZmhbv40khnu2VzfuIrt
         RuKPzjq/yKKSslRuNQ4roKjUwakzDaodcItiQjhNGlMRWsn5pdPBLTXcLTTrCyiT3gu9
         dv7X4VxrJJzKzEJppxPvaFWBLfWWs2x8l2FuzdyS5hDMYu3jZEHAMF6J+3SO7DegWYrs
         yQlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y9si317972pgg.15.2019.03.28.15.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:46:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav109.sakura.ne.jp (fsav109.sakura.ne.jp [27.133.134.236])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2SMk1nx051674;
	Fri, 29 Mar 2019 07:46:01 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav109.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav109.sakura.ne.jp);
 Fri, 29 Mar 2019 07:46:01 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav109.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126072090247.bbtec.net [126.72.90.247])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2SMjqDP051640
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Fri, 29 Mar 2019 07:46:01 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: Re: sysrq key f to trigger OOM manually
To: Vincent Li <vincent.mc.li@gmail.com>
References: <CAK3+h2xjr_h-3D9952SPUpN1HadyLz13gFmsAZWSTx9uz0sO3Q@mail.gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <fcf5dd0b-8e96-7512-b76a-65a74e5fd52f@I-love.SAKURA.ne.jp>
Date: Fri, 29 Mar 2019 07:45:53 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <CAK3+h2xjr_h-3D9952SPUpN1HadyLz13gFmsAZWSTx9uz0sO3Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/03/29 6:37, Vincent Li wrote:
> Hi,
> 
> not sure if this is the right place, I tried to use echo f >
> /proc/sysrq-trigger to manually trigger OOM, the OOM killer is
> triggered to kill a process, does it make sense to trigger OOM killer
> manually but not actually kill the process, this could be useful to
> diagnosis problem without actually killing a process in production
> box.

Why not use "/usr/bin/top -o %MEM" etc. ?
Reading from /proc will give you more information than from SysRq.

