Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE0436B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:55:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b140so13518568wme.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:55:07 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id g68si10586993wme.88.2017.03.13.04.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 04:55:06 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id v190so9402923wme.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:55:06 -0700 (PDT)
Date: Mon, 13 Mar 2017 14:55:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: don't warn when vmalloc() fails due to a fatal signal
Message-ID: <20170313115504.7qyyoxwycqnfh5yr@node.shutemov.name>
References: <20170313114425.72724-1-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313114425.72724-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: aryabinin@virtuozzo.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Mar 13, 2017 at 12:44:25PM +0100, Dmitry Vyukov wrote:
> When vmalloc() fails it prints a very lengthy message with all the
> details about memory consumption assuming that it happened due to OOM.
> However, vmalloc() can also fail due to fatal signal pending.
> In such case the message is quite confusing because it suggests that
> it is OOM but the numbers suggest otherwise. The messages can also
> pollute console considerably.
> 
> Don't warn when vmalloc() fails due to fatal signal pending.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
