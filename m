Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 340306B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 12:16:46 -0400 (EDT)
Message-ID: <29949019.1255968993574.JavaMail.root@ps29>
Date: Mon, 19 Oct 2009 17:16:33 +0100 (GMT+01:00)
From: "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
Reply-To: "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC]get_swap_page():delay update swap_list.next
MIME-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bo Liu <bo-liu@hotmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Oct 2009 you wrote:

> If scan_swap_map() successed in current si, there is no
> need to update swap_list.next.So get_swap_page next time
> called can start search from the last swap_info(which still
> have free slots).

No, I think you'll find that's mistaken.  It is intended behaviour that
allocating from two swap areas of the same priority will alternate
between them page by page (or cycle around three or more of
the same priority) - a kind of poor man's striping.

You may think that's silly, and not want that behaviour: in which
case assign different priorities to those swap areas, and it will
then behave like you were changing the same priority case to
behave.  So there is no reason to make your change.

Hugh

[I apologize for breaking the threading on your mail: I've been
caught by surprise to find myself unable to reply in the usual way.]




Get 50% off Norton Security- http://www.tiscali.co.uk/securepc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
