Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7A7EC6B0055
	for <linux-mm@kvack.org>; Thu, 21 May 2009 15:17:15 -0400 (EDT)
Message-ID: <4A15A8C7.2030505@redhat.com>
Date: Thu, 21 May 2009 15:17:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page	allocator
References: <20090520183045.GB10547@oblivion.subreption.com>
In-Reply-To: <20090520183045.GB10547@oblivion.subreption.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Larry H. wrote:
> This patch adds support for the SENSITIVE flag to the low level page
> allocator. An additional GFP flag is added for use with higher level
> allocators (GFP_SENSITIVE, which implies GFP_ZERO).

Sensitive to what?  Allocation failures?

Kidding, I read the rest of your emails.  However,
chances are whoever runs into the code later on
will not read everything.

Would GFP_CONFIDENTIAL & PG_confidential be a better
name, since it indicates the page stores confidential
information, which should not be leaked?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
