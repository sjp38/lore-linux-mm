Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6674F6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 18:28:00 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id uo6so107181935pac.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:28:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x2si4913131pfi.97.2016.01.26.15.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 15:27:59 -0800 (PST)
Date: Tue, 26 Jan 2016 15:27:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] mm/madvise: pass return code of memory_failure() to
 userspace
Message-Id: <20160126152758.0638a764ba99ab215c44977c@linux-foundation.org>
In-Reply-To: <1453451277-20979-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1453451277-20979-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Chen Gong <gong.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 22 Jan 2016 17:27:57 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently the return value of memory_failure() is not passed to userspace, which
> is inconvenient for test programs that want to know the result of error handling.
> So let's return it to the caller as we already do in MADV_SOFT_OFFLINE case.

I updated this to mention that it's for madvise(MADV_HWPOISON):

: Currently the return value of memory_failure() is not passed to userspace
: when madvise(MADV_HWPOISON) is used.  This is inconvenient for test
: programs that want to know the result of error handling.  So let's return
: it to the caller as we already do in the MADV_SOFT_OFFLINE case.

btw, MADV_SOFT_OFFLINE and MADV_HWPOISON are not documented in that
comment block over sys_madvise().  Fixy please?  You might want to
check that no other MADV_foo values have been omitted.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
