Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id DBF6B6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 02:04:41 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id y20so789ier.0
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 23:04:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v12si263971ioi.18.2014.11.24.23.04.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Nov 2014 23:04:40 -0800 (PST)
Date: Mon, 24 Nov 2014 23:05:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add parameter to disable faultaround
Message-Id: <20141124230502.30f9b6f0.akpm@linux-foundation.org>
In-Reply-To: <1416898318-17409-1-git-send-email-chanho.min@lge.com>
References: <1416898318-17409-1-git-send-email-chanho.min@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chanho Min <chanho.min@lge.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, HyoJun Im <hyojun.im@lge.com>, Gunho Lee <gunho.lee@lge.com>, Wonhong Kwon <wonhong.kwon@lge.com>

On Tue, 25 Nov 2014 15:51:58 +0900 Chanho Min <chanho.min@lge.com> wrote:

> The faultaround improves the file read performance, whereas pages which
> can be dropped by drop_caches are reduced. On some systems, The amount of
> freeable pages under memory pressure is more important than read
> performance.

The faultaround pages *are* freeable.  Perhaps you meant "free" here.

Please tell us a great deal about the problem which you are trying to
solve.  What sort of system, what sort of workload, what is bad about
the behaviour which you are observing, etc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
