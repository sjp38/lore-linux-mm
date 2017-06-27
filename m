Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9CB06B02F4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:49:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b11so6951437wmh.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 13:49:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 53si196271wru.4.2017.06.27.13.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 13:49:28 -0700 (PDT)
Date: Tue, 27 Jun 2017 13:49:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] v2 mm subsystem refcounter conversions
Message-Id: <20170627134926.dbcedc32e0519bd341bd03a5@linux-foundation.org>
In-Reply-To: <1498564127-11097-1-git-send-email-elena.reshetova@intel.com>
References: <1498564127-11097-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Elena Reshetova <elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, keescook@chromium.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, arnd@arndb.de, luto@kernel.org

On Tue, 27 Jun 2017 14:48:42 +0300 Elena Reshetova <elena.reshetova@intel.com> wrote:

> No changes in patches apart from trivial rebases, but now by
> default refcount_t = atomic_t and uses all atomic standard operations
> unless CONFIG_REFCOUNT_FULL is enabled. This is a compromize for the
> systems that are critical on performance and cannot accept even
> slight delay on the refcounter operations.

OK, thanks - I'll save these up for consideration after the 4.12 release.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
