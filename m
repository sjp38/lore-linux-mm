Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 093CA6B03AE
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:44:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o74so65801321pfi.6
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:44:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p71si33673862pfa.29.2017.06.06.04.44.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 04:44:24 -0700 (PDT)
Subject: Re: [PATCH 4/5] Make LSM Writable Hooks a command line option
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <71e91de0-7d91-79f4-67f0-be0afb33583c@schaufler-ca.com>
	<201706060550.HAC69712.OVFOtSFLQJOMFH@I-love.SAKURA.ne.jp>
	<ff5714b2-bbb0-726d-2fe6-13d4f1a30a38@huawei.com>
	<201706061954.GBH56755.QSOOFMFLtJFVOH@I-love.SAKURA.ne.jp>
	<6c807793-6a39-82ef-93d9-29ad2546fc4c@huawei.com>
In-Reply-To: <6c807793-6a39-82ef-93d9-29ad2546fc4c@huawei.com>
Message-Id: <201706062042.GAC86916.FMtHOOFJOSVLFQ@I-love.SAKURA.ne.jp>
Date: Tue, 6 Jun 2017 20:42:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: igor.stoppa@huawei.com, casey@schaufler-ca.com, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Igor Stoppa wrote:
> Who decides when enough is enough, meaning that all the needed modules
> are loaded?
> Should I provide an interface to user-space? A sysfs entry?

No such interface is needed. Just an API for applying set_memory_rw()
and set_memory_ro() on LSM hooks is enough.

security_add_hooks() can call set_memory_rw() before adding hooks and
call set_memory_ro() after adding hooks. Ditto for security_delete_hooks()
for SELinux's unregistration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
