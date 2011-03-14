Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 633EF8D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:33:45 -0400 (EDT)
Received: by iwl42 with SMTP id 42so7070259iwl.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 08:33:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
References: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
Date: Tue, 15 Mar 2011 00:25:32 +0900
Message-ID: <AANLkTimEmv66taMnmNqTHHtoYu4bGAz3BRGbF0ncB40L@mail.gmail.com>
Subject: Re: [PATCH] thp+memcg-numa: fix BUG at include/linux/mm.h:370!
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 14, 2011 at 5:08 PM, Hugh Dickins <hughd@google.com> wrote:
> THP's collapse_huge_page() has an understandable but ugly difference
> in when its huge page is allocated: inside if NUMA but outside if not.
> It's hardly surprising that the memcg failure path forgot that, freeing
> the page in the non-NUMA case, then hitting a VM_BUG_ON in get_page()
> (or even worse, using the freed page).
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks, Hugh.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
