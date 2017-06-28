Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE516B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 04:28:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v62so49110769pfd.10
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 01:28:00 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i145si4150293wmf.4.2017.06.28.01.27.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 01:27:59 -0700 (PDT)
Subject: Re: [PATCH 3/3] Make LSM Writable Hooks a command line option
References: <20170627173323.11287-1-igor.stoppa@huawei.com>
 <20170627173323.11287-4-igor.stoppa@huawei.com>
 <20170627175118.GA14286@infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <bd570517-c05f-7f37-aba0-6e4c14938dfb@huawei.com>
Date: Wed, 28 Jun 2017 11:25:37 +0300
MIME-Version: 1.0
In-Reply-To: <20170627175118.GA14286@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor
 Stoppa <igor.stoppa@gmail.com>

Resending my reply, I mistakenly used the wrong mail account yesterday
and my reply didn't et to the ml.

On 27/06/17 20:51, Christoph Hellwig wrote:
> On Tue, Jun 27, 2017 at 08:33:23PM +0300, Igor Stoppa wrote:

[...]

>> The default value is disabled, unless SE Linux debugging is turned on.
> 
> Can we please just force it to be read-only?

I'm sorry, I'm not quite sure I understand your comment.

I'm trying to replicate the behavior of __lsm_ro_after_init:

line 1967 @ [1]   - Did I get it wrong?

thanks, igor



[1]
https://kernel.googlesource.com/pub/scm/linux/kernel/git/jmorris/linux-security/+/5965453d5e3fb425e6f9d6b4fec403bda3f33107/include/linux/lsm_hooks.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
