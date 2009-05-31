Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 294936B00FD
	for <linux-mm@kvack.org>; Sat, 30 May 2009 22:14:52 -0400 (EDT)
Message-ID: <4A21E816.4050203@redhat.com>
Date: Sat, 30 May 2009 22:14:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Use kzfree in mac80211 key handling to enforce data	sanitization
References: <20090531015801.GB8941@oblivion.subreption.com>
In-Reply-To: <20090531015801.GB8941@oblivion.subreption.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, pageexec@freemail.hu, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Larry H. wrote:
> [PATCH] Use kzfree in mac80211 key handling to enforce data sanitization
> 
> This patch replaces the kfree() calls within the mac80211 WEP RC4 key
> handling and ieee80211 management APIs with kzfree(), to enforce
> sanitization of the key buffer contents.
> 
> This prevents the keys from persisting on memory, potentially
> leaking to other kernel users after re-allocation of the memory by
> the LIFO allocators, or in coldboot attack scenarios. Information can be
> leaked as well due to use of uninitialized variables, or other bugs.
> 
> This patch doesn't affect fastpaths.

This seems to be essentially what Ingo proposed.

Clearing out a buffer that held a wifi key on free
makes sense, even for systems that are not in
paranoid mode.

> Signed-off-by: Larry Highsmith <research@subreption.com>

Acked-by: Rik van Riiel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
