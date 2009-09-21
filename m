Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 135716B0158
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 09:04:28 -0400 (EDT)
Message-ID: <4AB77BEF.1050207@redhat.com>
Date: Mon, 21 Sep 2009 16:13:19 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: fix rare page leak
References: <Pine.LNX.4.64.0909211336300.4809@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909211336300.4809@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> In the rare case when stable_tree_insert() finds a match when the prior
> stable_tree_search() did not, it forgot to free the page reference (the
> omission looks intentional, but I think that's because something else
> used to be done there).
>
> Fix that by one put_page() for all three cases, call it tree_page
> rather than page2[0], clarify the comment on this exceptional case,
> and remove the comment in stable_tree_search() which contradicts it!
>   

I feel small embarrassment, I probably copy-pasted the body of 
unstable_tree_search_insert() when I wrote it.
Good catch Hugh.

Acked-by: Izik Eidus <ieidus@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
