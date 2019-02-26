Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4391C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 10:25:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63D9420842
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 10:25:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63D9420842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8A438E0004; Tue, 26 Feb 2019 05:25:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B39998E0001; Tue, 26 Feb 2019 05:25:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4F968E0004; Tue, 26 Feb 2019 05:25:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0C48E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 05:25:50 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id l10so9940856iob.22
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:25:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=EiWZ15bNWgJfJPRYdhtjLe1Xq4TOZM0/tcUrRrWql1g=;
        b=CBSyRLQbzdm3RsrmezYrxC252kQotC7ZeXXO7zBFfq8aPbZgSvHGksfr2rU07iARWb
         lF5QrZzwOYKyKd2Jbv9vYkXCcDQ5NTkQgTvhTpHt7cKVnETwfJsaqigUv/n0re6sZQZx
         cKW2kVe8qJlL7T2Si7zaz/UmEKgJNMn1dUjMK3072cEB6DPAcSEhGpVBd0k3leCQvhHS
         D3EnXzTYbbZ2WrbVamrA6fvfpnDkSjIrRI85PNkJktR99P8sxAhk19yl4BPXen2FLpHD
         mtRr7JlnB7GDfK6X+dTL29yEWM/h2yAy40BNODMcNJjeeo5sUEuD1xnlIZhKiv6+YtiT
         Q5XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuaFV+qsdWbfGT6n+glaGBE0KbJJaQYZR6lfo8GQymMxs2aM2alc
	IGRCjBx9YWChOdbDV5ST+JofJeeyl48tJoFZbHDzhyn3/ZI5CwNTN+PMqfISyrx5Jyex5UvRBsD
	va4zE3IeujlBKe7/tevjsp7/MEBC22kiSnlcfBgBc1xXKRKuEwi56ctWEPLe0EWfAJw==
X-Received: by 2002:a6b:7941:: with SMTP id j1mr12216218iop.262.1551176750225;
        Tue, 26 Feb 2019 02:25:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZHUP1RhKTvrNmxfBJx7yQ0e0+k1kypveX0nqk5s36/boWjiJ0uDX+WVALVS1mWZIo1ywpq
X-Received: by 2002:a6b:7941:: with SMTP id j1mr12216183iop.262.1551176749369;
        Tue, 26 Feb 2019 02:25:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551176749; cv=none;
        d=google.com; s=arc-20160816;
        b=Kdv5YyuHaazeR0QHvP7rF+JtRrFx6AKwgPhjjAoX3rDBzXDNYuiYQXu1Pr+8qN7nIa
         gj+wViLVq+UPIcVgkraaATiPIF8XMgtIa8bD1ocQ/PsIAI/pcSvHfd5/ODaSZuO2qVOR
         ay5YAXHNZTPMyPinlJsWOoa4MIndDaXpxQT+c6xxVG9rhiqPWP3YJovxg8Zcsb4SHfI3
         KQpcVeC9c+oOEwp7m2PV5Ov9cDYfGjHgF1vUhPGM7NjQpwFKl7LTnOjauvVII7YnihoH
         VUXxrFDkF33fXpVe+02EBkZiuT8kfHVd82IddDBce5DvyWYrlREZNgRdbNHajVKVZTSO
         9WUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=EiWZ15bNWgJfJPRYdhtjLe1Xq4TOZM0/tcUrRrWql1g=;
        b=flMJwtJL4R56ZwCY6snjIihSLHYsH1qYCSX80J4EndUcDshtdaGvU/YcCVdIYjC7/C
         Oj6joDMlkL0IxVtMmh/jBj+qghM7PzR1j9AAMiphwhQxf54Ypvg8+1Jaabkv1FDYcLOq
         rC4yPDWdKVnaCQVQRKFOJ3MU8QlQnR4jhYAnRJVeImNGojd2HM0YFrsNUy3e0GKpYF+j
         CHKCEWkuy21PRUjKzKCw9cSwViLmXRamOWi76qhgjhu1wVq+uGAlYSxm5BpYXcoroWTQ
         FFSdUYsnB3ABQxAe0PidzyargQV166havhafPXthf1gp+RD7rI58/vkSRHxdD8GE6mZ5
         wc5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y65si6056264jad.18.2019.02.26.02.25.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 02:25:49 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav103.sakura.ne.jp (fsav103.sakura.ne.jp [27.133.134.230])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1QAOwwa000239;
	Tue, 26 Feb 2019 19:24:58 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav103.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav103.sakura.ne.jp);
 Tue, 26 Feb 2019 19:24:58 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav103.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1QAOvCb000234
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 26 Feb 2019 19:24:58 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
To: Petr Mladek <pmladek@suse.com>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org,
        linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>,
        Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>,
        linux-kernel@vger.kernel.org,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
References: <20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
 <20180420101751.6c1c70e8@gandalf.local.home>
 <20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
 <20180420111307.44008fc7@gandalf.local.home>
 <20180423103232.k23yulv2e7fah42r@pathway.suse.cz>
 <20180423073603.6b3294ba@gandalf.local.home>
 <20180423124502.423fb57thvbf3zet@pathway.suse.cz>
 <20180425053146.GA25288@jagdpanzerIV>
 <20180426094211.okftwdzgfn72rik3@pathway.suse.cz>
 <20180427102245.GA591@jagdpanzerIV>
 <20180509120050.eyuprdh75grhdsh4@pathway.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <63adb127-bb4b-d952-73f4-764d0cd78c52@i-love.sakura.ne.jp>
Date: Tue, 26 Feb 2019 19:24:59 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20180509120050.eyuprdh75grhdsh4@pathway.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2018/05/09 21:00, Petr Mladek wrote:
>>>> But we first need a real reason. Right now it looks to me like
>>>> we have "a solution" to a problem which we have never witnessed.
>>>
>>> I am trying to find a "simple" and generic solution for the problem
>>> reported by Tejun:
>> [..]
>>> 1. Console is IPMI emulated serial console.  Super slow.  Also
>>>    netconsole is in use.
>>> 2. System runs out of memory, OOM triggers.
>>> 3. OOM handler is printing out OOM debug info.
>>> 4. While trying to emit the messages for netconsole, the network stack
>>>    / driver tries to allocate memory and then fail, which in turn
>>>    triggers allocation failure or other warning messages.  printk was
>>>    already flushing, so the messages are queued on the ring.
>>> 5. OOM handler keeps flushing but 4 repeats and the queue is never
>>>    shrinking.  Because OOM handler is trapped in printk flushing, it
>>>    never manages to free memory and no one else can enter OOM path
>>>    either, so the system is trapped in this state.
>>> </paste>
> 
> IMHO, we do not need to chase down this particular problem. It was
> already "solved" by the commit 400e22499dd92613821 ("mm: don't warn
> about allocations which stall for too long").

Does memory allocation by network stack / driver while trying to emit
the messages include __GFP_DIRECT_RECLAIM flag (e.g. GFP_KERNEL) ?
Commit 400e22499dd92613821 handles only memory allocations with
__GFP_DIRECT_RECLAIM flag. If memory allocation when trying to emit
the messages does not include __GFP_DIRECT_RECLAIM flag (e.g.
GFP_ATOMIC / GFP_NOWAIT), doesn't this particular problem still exist?

