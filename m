Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB89E6B03A7
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 13:51:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d5so32432241pfe.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:51:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h64si451478pfc.82.2017.06.27.10.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 10:51:33 -0700 (PDT)
Date: Tue, 27 Jun 2017 10:51:18 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3] Make LSM Writable Hooks a command line option
Message-ID: <20170627175118.GA14286@infradead.org>
References: <20170627173323.11287-1-igor.stoppa@huawei.com>
 <20170627173323.11287-4-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170627173323.11287-4-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@gmail.com>

On Tue, Jun 27, 2017 at 08:33:23PM +0300, Igor Stoppa wrote:
> From: Igor Stoppa <igor.stoppa@gmail.com>
> 
> This patch shows how it is possible to take advantage of pmalloc:
> instead of using the build-time option __lsm_ro_after_init, to decide if
> it is possible to keep the hooks modifiable, now this becomes a
> boot-time decision, based on the kernel command line.
> 
> This patch relies on:
> 
> "Convert security_hook_heads into explicit array of struct list_head"
> Author: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> to break free from the static constraint imposed by the previous
> hardening model, based on __ro_after_init.
> 
> The default value is disabled, unless SE Linux debugging is turned on.

Can we please just force it to be read-only?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
