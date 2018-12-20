Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D54CE8E0004
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 20:46:48 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id m13so126619pls.15
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 17:46:48 -0800 (PST)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id k17si17133974pgl.62.2018.12.19.17.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 19 Dec 2018 17:46:47 -0800 (PST)
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
 <40a63aa5-edb6-4673-b4cc-1bc10e7b3953@windriver.com>
 <20181130181956.eewrlaabtceekzyu@linutronix.de>
 <e7795912-7d93-8f4e-b997-67c4ac1f3549@windriver.com>
 <20181205191400.qrhim3m3ak5hcsuh@linutronix.de>
 <16ac893a-a080-18a5-e636-7b7668d978b0@windriver.com>
 <20181218150744.GB20197@arrakis.emea.arm.com>
 <20181219153022.w5le6nf7meiogh72@linutronix.de>
From: He Zhe <zhe.he@windriver.com>
Message-ID: <b967b22a-78a9-5b73-9b04-26085f796e5d@windriver.com>
Date: Thu, 20 Dec 2018 09:46:34 +0800
MIME-Version: 1.0
In-Reply-To: <20181219153022.w5le6nf7meiogh72@linutronix.de>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Catalin Marinas <catalin.marinas@arm.com>
Cc: tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org



On 2018/12/19 23:30, Sebastian Andrzej Siewior wrote:
> On 2018-12-18 15:07:45 [+0000], Catalin Marinas wrote:
> …
>> It may be worth running some performance/latency tests during kmemleak
>> scanning (echo scan > /sys/kernel/debug/kmemleak) but at a quick look,
>> I don't think we'd see any difference with a raw_spin_lock_t.
>>
>> With a bit more thinking (though I'll be off until the new year), we
>> could probably get rid of the kmemleak_lock entirely in scan_block() and
>> make lookup_object() and the related rbtree code in kmemleak RCU-safe.
> Okay. So let me apply that patch into my RT tree with your ack (from the
> other email). And then I hope that it either shows up upstream or gets
> replaced with RCU in the ende :)

I'd like to do the upstreaming or replacing. Thanks.

Zhe

>
> Thanks.
>
> Sebastian
>
