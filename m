Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B54D6B0279
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 10:52:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l22so48213575pfb.11
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 07:52:58 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id j3si28179019pgs.370.2017.06.06.07.52.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 07:52:57 -0700 (PDT)
Subject: Re: [PATCH 4/5] Make LSM Writable Hooks a command line option
References: <ff5714b2-bbb0-726d-2fe6-13d4f1a30a38@huawei.com>
 <201706061954.GBH56755.QSOOFMFLtJFVOH@I-love.SAKURA.ne.jp>
 <6c807793-6a39-82ef-93d9-29ad2546fc4c@huawei.com>
 <201706062042.GAC86916.FMtHOOFJOSVLFQ@I-love.SAKURA.ne.jp>
 <4c3e3b8b-6507-7da5-1537-1e0ce04fcba5@huawei.com>
 <201706062336.CFE35913.OFFLQOHMtSJFVO@I-love.SAKURA.ne.jp>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <bff5442e-9ecd-9493-7397-7030ade63e81@huawei.com>
Date: Tue, 6 Jun 2017 17:51:26 +0300
MIME-Version: 1.0
In-Reply-To: <201706062336.CFE35913.OFFLQOHMtSJFVO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, casey@schaufler-ca.com, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 06/06/17 17:36, Tetsuo Handa wrote:
> Igor Stoppa wrote:
>> For the case at hand, would it work if there was a non-API call that you
>> could use until the API is properly expanded?
> 
> Kernel command line switching (i.e. this patch) is fine for my use cases.
> 
> SELinux folks might want
> 
> -static int security_debug;
> +static int security_debug = IS_ENABLED(CONFIG_SECURITY_SELINUX_DISABLE);

ok, thanks, I will add this

> so that those who are using SELINUX=disabled in /etc/selinux/config won't
> get oops upon boot by default. If "unlock the pool" were available,
> SELINUX=enforcing users would be happy. Maybe two modes for rw/ro transition helps.
> 
>   oneway rw -> ro transition mode: can't be made rw again by calling "unlock the pool" API
>   twoway rw <-> ro transition mode: can be made rw again by calling "unlock the pool" API

This was in the first cut of the API, but I was told that it would
require further rework, to make it ok for upstream, so we agreed to do
first the lockdown/destroy only part and the the rewrite.

Is there really a valid use case for unloading SE Linux?
Or any other security module.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
