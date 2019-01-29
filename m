Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A13BBC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2117620881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:12:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2117620881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE0F68E0002; Tue, 29 Jan 2019 16:12:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A901F8E0001; Tue, 29 Jan 2019 16:12:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A6C88E0002; Tue, 29 Jan 2019 16:12:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA828E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:12:30 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id v3so16924567itf.4
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:12:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LTCGq2rfIqNLXmMzc6ZGIoYk/oYmZWQwVqGaIu1ayRk=;
        b=SNIBZEarp/87G+xzOes9AVzfjxgmmexvstiVpNmvHthwD6hMVE43jTJgbFyLisgUPr
         Z+KVkLgYE7Ytymx7fAlcMT8J69vIGFeHh3S0rx631d9rbKnakZfwBnXPwalHEvQqT/K6
         6JhiEKvFlTCuuiAN6F1uYZGV0Ohyl4WiW7P53dc09dV09IMxk+qWAoeZ6q4tIRZyqLfq
         9LhbVaBp7gnU5FtPW67Poe8cQQihhTSIqy5JVRJ4CFrHEYNE+AoWwmRFE7ILaCib1D5t
         L7Ww92lyvSK6QagD7qJPlZ3drpU9MvliGNAu8olmBWyqXFW0w1lZBFXQv9D/4cV/Zz8d
         357A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukedZwt6+kynm50NUhcuNQstkrNhMKUAyYubvjdACXWbU3qY/hKQ
	fwI/TfO/kSgGxfucFowgyTtslgsdK5ffgrbo42JcSB87Mi5vWUqS7mBk02HI/NFszY4wNdqrXua
	1c4/EeFBNJyIqUjQC8Nyntk/ofqYf7t5gTSCxxphMRuAQkdRL+/PU7vvrRmCyDB1giA==
X-Received: by 2002:a02:6915:: with SMTP id e21mr17812358jac.142.1548796350179;
        Tue, 29 Jan 2019 13:12:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5ixbyEAWihzt0Og+iw0uROQD6scM7nLE3nGgHPUYe9kolhOwIx3JSBbRgoc9DOpuEicx+f
X-Received: by 2002:a02:6915:: with SMTP id e21mr17812322jac.142.1548796349507;
        Tue, 29 Jan 2019 13:12:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548796349; cv=none;
        d=google.com; s=arc-20160816;
        b=ILMWl21rp4CRu0wg8O2Xz+zwxV2HSmkYN3r4LmCYzKYFdyVW9ueZOvCD/gAfpn9JTI
         mDzAX/d77+vmPPbcRlALlEZOmXW0abPkR3FMUcar7WfkqPJGsXEAel3EQHGe1epgO/2r
         uEbd0qR3RXLSCY1DrpjiMlPLw4hXCB3wm7CdvZepIK1sKPl3joKkM9Dn9nblBA1HLueE
         HtsQewhYGByt7xH3MKUe0wjz6FpHSUo5ExV2DUsQzzDZpTjFKWQI+saenrikcvCcWO2V
         v/Ye0frxYekJCBQVWoYd4mekpmc1SU3PJOVy9ZaenuVWHLfJ1Fl5iaxFDg6Q54Pno9DP
         p/FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=LTCGq2rfIqNLXmMzc6ZGIoYk/oYmZWQwVqGaIu1ayRk=;
        b=aL79KuXhDVYgusaIFWdRhjAu1bgpsRsrDe5H59F50t610LYocMcDM5zy25I6HX9Ukg
         oEQuD8bkek/285vs2bonAIDZfK6HJFCL/AUgR9kJNnwcSx7GVkHqEQG/jLLn+/xOXrU/
         euuygiTGjxbPIA93/Z+iqeKmjTQ4L+XAc3UFUmDByuI/FWLQr7Vi0Cbud+OxLf04t2Ht
         b9lN42Z1jVp/nTtisWkKu6eFtp1/4eUXLjHjrCUQTNvtOTwGp0n1uEt7qgmbLLj8nYOj
         YsiwafSQJ8BUKHC4nhHJoCfaGOZttOmCY1rWB5mTc3EF6OKXpmh5mNi+EaqI95KV/P9B
         ER1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j185si2382779ite.5.2019.01.29.13.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 13:12:29 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav405.sakura.ne.jp (fsav405.sakura.ne.jp [133.242.250.104])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0TLCPPx066936;
	Wed, 30 Jan 2019 06:12:25 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav405.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp);
 Wed, 30 Jan 2019 06:12:25 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x0TLCKem066812
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 30 Jan 2019 06:12:25 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiufei Xue <jiufei.xue@linux.alibaba.com>, linux-mm@kvack.org,
        joseph.qi@linux.alibaba.com,
        Linus Torvalds <torvalds@linux-foundation.org>
References: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
 <132b9310-2478-19e1-aed3-48a2b448ca50@I-love.SAKURA.ne.jp>
 <20190129111346.fbb11cc79c09b7809f447bef@linux-foundation.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
Date: Wed, 30 Jan 2019 06:12:16 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129111346.fbb11cc79c09b7809f447bef@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/01/30 4:13, Andrew Morton wrote:
> On Tue, 29 Jan 2019 20:43:20 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
>> On 2019/01/29 16:21, Jiufei Xue wrote:
>>> Trinity reports BUG:
>>>
>>> sleeping function called from invalid context at mm/vmalloc.c:1477
>>> in_atomic(): 1, irqs_disabled(): 0, pid: 12269, name: trinity-c1
>>>
>>> [ 2748.573460] Call Trace:
>>> [ 2748.575935]  dump_stack+0x91/0xeb
>>> [ 2748.578512]  ___might_sleep+0x21c/0x250
>>> [ 2748.581090]  remove_vm_area+0x1d/0x90
>>> [ 2748.583637]  __vunmap+0x76/0x100
>>> [ 2748.586120]  __se_sys_swapon+0xb9a/0x1220
>>> [ 2748.598973]  do_syscall_64+0x60/0x210
>>> [ 2748.601439]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>
>>> This is triggered by calling kvfree() inside spinlock() section in
>>> function alloc_swap_info().
>>> Fix this by moving the kvfree() after spin_unlock().
>>>
>>
>> Excuse me? But isn't kvfree() safe to be called with spinlock held?
> 
> Yes, I'm having trouble spotting where kvfree() can sleep.  Perhaps it
> *used* to sleep on mutex_lock(vmap_purge_lock), but
> try_purge_vmap_area_lazy() is using mutex_trylock().  Confused.
> 
> kvfree() darn well *shouldn't* sleep!
> 

If I recall correctly, there was an attempt to allow vfree() to sleep
but that attempt failed, and the change to allow vfree() to sleep was
reverted. Thus, vfree() had been "Context: Any context except NMI.".

If we want to allow vfree() to sleep, at least we need to test with
kvmalloc() == vmalloc() (i.e. force kvmalloc()/kvfree() users to use
vmalloc()/vfree() path). For now, reverting the 
"Context: Either preemptible task context or not-NMI interrupt." change
will be needed for stable kernels.

