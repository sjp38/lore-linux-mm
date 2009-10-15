Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C70446B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 11:03:09 -0400 (EDT)
Message-ID: <4AD739A0.6010707@redhat.com>
Date: Thu, 15 Oct 2009 11:02:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/9] swap_info: change to array of pointers
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils> <Pine.LNX.4.64.0910150146210.3291@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0910150146210.3291@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nigel Cunningham <ncunningham@crca.org.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> The swap_info_struct is only 76 or 104 bytes, but it does seem wrong
> to reserve an array of about 30 of them in bss, when most people will
> want only one.  Change swap_info[] to an array of pointers.
> 
> That does need a "type" field in the structure: pack it as a char with
> next type and short prio (aha, char is unsigned by default on PowerPC).
> Use the (admittedly peculiar) name "type" throughout for this index.
> 
> /proc/swaps does not take swap_lock: I wouldn't want it to, but do take
> care with barriers when adding a new item to the array (never removed).
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
