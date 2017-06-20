Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE3E36B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 00:04:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s65so119297605pfi.14
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:04:06 -0700 (PDT)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id 3si1822801plr.637.2017.06.19.21.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 21:04:05 -0700 (PDT)
Received: by mail-pg0-x22c.google.com with SMTP id 132so23695019pgb.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:04:05 -0700 (PDT)
Date: Mon, 19 Jun 2017 21:04:03 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [kernel-hardening] [PATCH 21/23] usercopy: Restrict non-usercopy
 caches to size 0
Message-ID: <20170620040403.GA610@zzz.localdomain>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-22-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497915397-93805-22-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi David + Kees,

On Mon, Jun 19, 2017 at 04:36:35PM -0700, Kees Cook wrote:
> With all known usercopied cache whitelists now defined in the kernel, switch
> the default usercopy region of kmem_cache_create() to size 0. Any new caches
> with usercopy regions will now need to use kmem_cache_create_usercopy()
> instead of kmem_cache_create().
> 

While I'd certainly like to see the caches be whitelisted, it needs to be made
very clear that it's being done (the cover letter for this series falsely claims
that kmem_cache_create() is unchanged) and what the consequences are.  Is there
any specific plan for identifying caches that were missed?  If it's expected for
people to just fix them as they are found, then they need to be helped a little
--- at the very least by putting a big comment above report_usercopy() that
explains the possible reasons why the error might have triggered and what to do
about it.

- Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
