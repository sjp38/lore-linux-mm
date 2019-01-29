Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A43BC4151A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 11:43:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16F3F21852
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 11:43:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16F3F21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E3518E0002; Tue, 29 Jan 2019 06:43:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8925A8E0001; Tue, 29 Jan 2019 06:43:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 781748E0002; Tue, 29 Jan 2019 06:43:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6AA8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 06:43:29 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id z22so7505176oto.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 03:43:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=F47eZyr3tujitM7xr/LqiZ/xBxh3NOz1l8wGGFbsTbg=;
        b=WDjq/JtfbsnNlzzw3e6Srku8wzqO3Si2JQ8LnfGGM8DzIx2HYsN1AmIxeVIRaYHlbM
         QJabC5DXY3LFLoOnoMnQBYUQ+yAFAYhMGZm+zGhKmkRMv3XG2YhNIP4KBX5+Ord5lqK/
         PZGcA+gxW47fgX+/7q9HUo1cL2iSlp/DDMDynpbpQhe7US8scJL7Fee6V8Qgqg11L1dy
         5jOy/mG6j/GF4Kgmq6ZkAOlxG0VVvKKoBP0hLXmlYqjcEP24svGmy1p25T34E2yXW+8I
         X9h01nTs+awHkvUUzrSFN1cqvXOpyaBItNGAVSZq+Qg0je/IzpfF18AkArYG+pXPURyz
         E38w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAubJi7WsZdsFK+is2nKZTVEy+aI3Vn1o4/SaQbD53Iy6A8RGVeEM
	g+G6n/YhryvjK4brJjzBhWqCa8xjIKzDZt0j/FaLhmkU/vPKJu7y+E6n81CvQ3H/IqfrnGT5FnA
	UR10FfDUZt9Vxqa+nRfNlxEG/xaFldY01pBeMEe2ilXrpaFBAICdmnkbaaeuOGvZqKA==
X-Received: by 2002:aca:3e06:: with SMTP id l6mr9232514oia.299.1548762209096;
        Tue, 29 Jan 2019 03:43:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZyCqiHVm7P6DNLl4Eqgm8p5nrBCvCbQkpcDDrLQ5/gkfLhxCLsvE6ZTX4YETqZa8lZVWfp
X-Received: by 2002:aca:3e06:: with SMTP id l6mr9232491oia.299.1548762208476;
        Tue, 29 Jan 2019 03:43:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548762208; cv=none;
        d=google.com; s=arc-20160816;
        b=LUGdh6akRVcIUQGEHAxuuionKyVupotHlcXpB5yycvJRZJHmjA3LBslwpjieYq/V7T
         aONtsfVaQ9qNAgs73TSlpL9+Ymer7FdklUCKd32X49/OurlWyzIonnW74k9tZyjH1Xzh
         9TLSX2HmTTqYL6aTUDBUpwKMGphRe1h1b4SWOAb5asla7Vzhmn56WKARfbyzrfAhiUXj
         tF/ahSrq0AOX/LTbXjFS/QY/OUAmQAzQdh1VHyrCKACJCw36hFJTEsaG/uFhndCICT/H
         XV+mnj4PrDSyeHuwIL3Htu1Pug17lX18Zz45Ixx3bCM9iqVONy9d1rQVvhujugS6c5y8
         +bwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=F47eZyr3tujitM7xr/LqiZ/xBxh3NOz1l8wGGFbsTbg=;
        b=vFgjnrRDFjmUWi0p/PSjpx68IC5/7T9MD4F4WlwfhlIH0gYnYxZLZ7ohEWVGG+VxGH
         U7js8DtUoyUHQ9dsxujTx7c2EwGlA0cBBaE2ERHbiZMhGPex1nBnAMve1qAMRtHyjNAQ
         OiOR9A60YqHMmt2jx1smApukC3k/NVzstdAvQHBjb6G4/G+4WGKl+XffqTO5Sh1OGHNr
         oJF5xt8oyACibii6IJewxg8aF72GVv4TJ0lk+MnGVhp353I/yWtTIsUbDc0i6R71n0pO
         Re3BD8fTRKYu/cWAZSjlqk1ph2ZOnv/4hY5Fcos6B3VtETGLLLMteS/nPlLn/GHrsQxI
         lQoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g68si6664023otg.312.2019.01.29.03.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 03:43:28 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav104.sakura.ne.jp (fsav104.sakura.ne.jp [27.133.134.231])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0TBhOPm011385;
	Tue, 29 Jan 2019 20:43:24 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav104.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav104.sakura.ne.jp);
 Tue, 29 Jan 2019 20:43:24 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav104.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x0TBhOUE011335
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 29 Jan 2019 20:43:24 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Jiufei Xue <jiufei.xue@linux.alibaba.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, joseph.qi@linux.alibaba.com
References: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <132b9310-2478-19e1-aed3-48a2b448ca50@I-love.SAKURA.ne.jp>
Date: Tue, 29 Jan 2019 20:43:20 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/01/29 16:21, Jiufei Xue wrote:
> Trinity reports BUG:
> 
> sleeping function called from invalid context at mm/vmalloc.c:1477
> in_atomic(): 1, irqs_disabled(): 0, pid: 12269, name: trinity-c1
> 
> [ 2748.573460] Call Trace:
> [ 2748.575935]  dump_stack+0x91/0xeb
> [ 2748.578512]  ___might_sleep+0x21c/0x250
> [ 2748.581090]  remove_vm_area+0x1d/0x90
> [ 2748.583637]  __vunmap+0x76/0x100
> [ 2748.586120]  __se_sys_swapon+0xb9a/0x1220
> [ 2748.598973]  do_syscall_64+0x60/0x210
> [ 2748.601439]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> This is triggered by calling kvfree() inside spinlock() section in
> function alloc_swap_info().
> Fix this by moving the kvfree() after spin_unlock().
> 

Excuse me? But isn't kvfree() safe to be called with spinlock held?

There was no context explanation regarding kvfree() for 4.18.20.
4.19.18 says

  Context: Any context except NMI.

and 4.20.5 says

  Context: Either preemptible task context or not-NMI interrupt.

. There might be users who didn't notice this change.

