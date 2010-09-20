Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BB4DA6B0047
	for <linux-mm@kvack.org>; Sun, 19 Sep 2010 23:09:45 -0400 (EDT)
Message-ID: <4C96D072.5080305@redhat.com>
Date: Sun, 19 Sep 2010 23:09:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: further fix swapin race condition
References: <20100903153958.GC16761@random.random> <alpine.LSU.2.00.1009051926330.12092@sister.anvils> <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com> <20100915234237.GR5981@random.random> <alpine.DEB.2.00.1009151703060.7332@tigran.mtv.corp.google.com> <20100916210349.GU5981@random.random> <alpine.LSU.2.00.1009161905190.2517@tigran.mtv.corp.google.com> <20100918131907.GI18596@random.random> <alpine.LSU.2.00.1009191924110.2779@sister.anvils> <alpine.LSU.2.00.1009191938110.3025@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1009191938110.3025@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 09/19/2010 10:40 PM, Hugh Dickins wrote:
> Commit 4969c1192d15afa3389e7ae3302096ff684ba655 "mm: fix swapin race condition"
> is now agreed to be incomplete.  There's a race, not very much less likely
> than the original race envisaged, in which it is further necessary to check
> that the swapcache page's swap has not changed.

> B ought to have checked that page1's swap was still swap1.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> Cc: stable@kernel.org

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
