Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 12E9C6B005A
	for <linux-mm@kvack.org>; Sun, 31 May 2009 10:38:02 -0400 (EDT)
Message-ID: <4A22965A.6030201@redhat.com>
Date: Sun, 31 May 2009 10:38:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Use kzfree in crypto API context initialization and key/iv
 handling
References: <20090531025720.GC9033@oblivion.subreption.com>
In-Reply-To: <20090531025720.GC9033@oblivion.subreption.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-kernel@vger.kernel.org, pageexec@freemail.hu, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Larry H. wrote:
> [PATCH] Use kzfree in crypto API context initialization and key/iv handling
> 
> This patch replaces the kfree() calls within the crypto API (algorithms,
> key setup and handling, etc) with kzfree(), to enforce sanitization of
> the allocated memory.
> 
> This prevents such information from persisting on memory and eventually
> leak to other kernel users or during coldboot attacks.
> 
> This patch replaces kfree() for context (algorithm meta-data) structures
> too. Those are initialized or released once, and remain in use during the
> lifetime of the cipher/algorithm instance, therefore no performance impact
> exists for those specific changes.
> 
> This patch doesn't affect fastpaths.
> 
> Signed-off-by: Larry Highsmith <research@subreption.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
