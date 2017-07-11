Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52ABC6B04F5
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:39:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g46so31129903wrd.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 04:39:24 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id y23si10221687wra.330.2017.07.11.04.39.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 04:39:23 -0700 (PDT)
Subject: Re: [PATCH v10 0/3] mm: security: ro protection for dynamic data
References: <20170710150603.387-1-igor.stoppa@huawei.com>
 <201707112012.GBC05774.QOtOSLJVFHFOFM@I-love.SAKURA.ne.jp>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <4821f909-8885-654d-701e-3044c79d055f@huawei.com>
Date: Tue, 11 Jul 2017 14:37:39 +0300
MIME-Version: 1.0
In-Reply-To: <201707112012.GBC05774.QOtOSLJVFHFOFM@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, labbott@redhat.com, hch@infradead.org, casey@schaufler-ca.com
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com


On 11/07/17 14:12, Tetsuo Handa wrote:
> Igor Stoppa wrote:
>> - I had to rebase Tetsuo Handa's patch because it didn't apply cleanly
>>   anymore, I would appreciate an ACK to that or a revised patch, whatever 
>>   comes easier.
> 
> Since we are getting several proposals of changing LSM hooks and both your proposal
> and Casey's "LSM: Security module blob management" proposal touch same files, I think
> we can break these changes into small pieces so that both you and Casey can make
> future versions smaller.
> 
> If nobody has objections about direction of Igor's proposal and Casey's proposal,
> I think merging only "[PATCH 2/3] LSM: Convert security_hook_heads into explicit
> array of struct list_head" from Igor's proposal and ->security accessor wrappers (e.g.

I would like to understand if there is still interest about:

* "[PATCH 1/3] Protectable memory support"  which was my main interest
* "[PATCH 3/3] Make LSM Writable Hooks a command line option"
  which was the example of how to use [1/3]

>   #define selinux_security(obj) (obj->security)
>   #define smack_security(obj) (obj->security)
>   #define tomoyo_security(obj) (obj->security)
>   #define apparmor_security(obj) (obj->security)

For example, I see that there are various kzalloc calls that might be
useful to turn into pmalloc ones.

In general, I'd think that, after a transient is complete, where modules
are loaded by allocating dynamic data structures, they could be locked
down in read-only mode.

I have the feeling that, now that I have polished up the pmalloc patch,
the proposed use case is fading away.

Can it be adjusted to the new situation or should I look elsewhere for
an example that would justify merging pmalloc?


thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
