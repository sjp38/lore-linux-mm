Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 678696B02B4
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 10:38:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u8so76859489pgo.11
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 07:38:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v188si12613339pgb.116.2017.06.06.07.38.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 07:38:13 -0700 (PDT)
Subject: Re: [PATCH 4/5] Make LSM Writable Hooks a command line option
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <ff5714b2-bbb0-726d-2fe6-13d4f1a30a38@huawei.com>
	<201706061954.GBH56755.QSOOFMFLtJFVOH@I-love.SAKURA.ne.jp>
	<6c807793-6a39-82ef-93d9-29ad2546fc4c@huawei.com>
	<201706062042.GAC86916.FMtHOOFJOSVLFQ@I-love.SAKURA.ne.jp>
	<4c3e3b8b-6507-7da5-1537-1e0ce04fcba5@huawei.com>
In-Reply-To: <4c3e3b8b-6507-7da5-1537-1e0ce04fcba5@huawei.com>
Message-Id: <201706062336.CFE35913.OFFLQOHMtSJFVO@I-love.SAKURA.ne.jp>
Date: Tue, 6 Jun 2017 23:36:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: igor.stoppa@huawei.com, casey@schaufler-ca.com, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Igor Stoppa wrote:
> For the case at hand, would it work if there was a non-API call that you
> could use until the API is properly expanded?

Kernel command line switching (i.e. this patch) is fine for my use cases.

SELinux folks might want

-static int security_debug;
+static int security_debug = IS_ENABLED(CONFIG_SECURITY_SELINUX_DISABLE);

so that those who are using SELINUX=disabled in /etc/selinux/config won't
get oops upon boot by default. If "unlock the pool" were available,
SELINUX=enforcing users would be happy. Maybe two modes for rw/ro transition helps.

  oneway rw -> ro transition mode: can't be made rw again by calling "unlock the pool" API
  twoway rw <-> ro transition mode: can be made rw again by calling "unlock the pool" API

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
