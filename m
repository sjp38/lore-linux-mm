Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2C3E831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 15:53:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w138so172386578oiw.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 12:53:24 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id l85si7597003oig.256.2017.05.22.12.53.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 12:53:23 -0700 (PDT)
Subject: Re: [PATCH] LSM: Make security_hook_heads a local variable.
References: <20170520085147.GA4619@kroah.com>
 <1495365245-3185-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170522140306.GA3907@infradead.org>
 <d98f4cd5-3f21-3f7b-2842-12b9a009e453@schaufler-ca.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <d25e2fd3-da11-4ec0-8edc-f1327c04fa6e@huawei.com>
Date: Mon, 22 May 2017 22:50:09 +0300
MIME-Version: 1.0
In-Reply-To: <d98f4cd5-3f21-3f7b-2842-12b9a009e453@schaufler-ca.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, Greg
 KH <gregkh@linuxfoundation.org>, James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>

On 22/05/17 18:09, Casey Schaufler wrote:
> On 5/22/2017 7:03 AM, Christoph Hellwig wrote:

[...]

>> But even with those we can still chain
>> them together with a list with external linkage.
> 
> I gave up that approach in 2012. Too many unnecessary calls to
> null functions, and massive function vectors with a tiny number
> of non-null entries. From a data structure standpoint, it was
> just wrong. The list scheme is exactly right for the task at
> hand.

I understand this as a green light, for me to continue with the plan of
using LSM Hooks as example for making dynamically allocated data become
read-only, using also Tetsuo's patch (thanks, btw).

Is that correct?

---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
