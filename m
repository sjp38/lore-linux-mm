Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 017F4828EB
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 14:06:40 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id q63so50368644pfb.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 11:06:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v24si6206999pfi.109.2016.01.11.11.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 11:06:39 -0800 (PST)
Date: Mon, 11 Jan 2016 11:06:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4][for-next]mm: add a new vector based madvise syscall
Message-Id: <20160111110638.2227f50a289fe376739ad37c@linux-foundation.org>
In-Reply-To: <20160111190021.GA3589410@devbig084.prn1.facebook.com>
References: <d01698140a51cf9b2ce233c7574c2ece9f6fa241.1449791762.git.shli@fb.com>
	<20160111190021.GA3589410@devbig084.prn1.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, Kernel-team@fb.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Arnd Bergmann <arnd@arndb.de>

On Mon, 11 Jan 2016 11:00:22 -0800 Shaohua Li <shli@fb.com> wrote:

> any chance this can be added to -mm? It can still be applied to latest
> -next tree.

We have an utterly unbelievable amount of MM stuff queued for 4.4. 
I'll be taking a look at madvisev() after 4.5-rc1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
