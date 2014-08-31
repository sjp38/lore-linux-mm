Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 045D76B0035
	for <linux-mm@kvack.org>; Sun, 31 Aug 2014 11:27:37 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so10178886pab.17
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 08:27:37 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id pi6si9757228pac.39.2014.08.31.08.27.36
        for <linux-mm@kvack.org>;
        Sun, 31 Aug 2014 08:27:36 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/6] hugepage migration fixes (v3)
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Sun, 31 Aug 2014 08:27:35 -0700
In-Reply-To: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	(Naoya Horiguchi's message of "Thu, 28 Aug 2014 21:38:54 -0400")
Message-ID: <87tx4sk7bs.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> This is the ver.3 of hugepage migration fix patchset.

I wonder how far we are away from support THP migration with the
standard migrate_pages() syscall?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
