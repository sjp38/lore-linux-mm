Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 51D746B0062
	for <linux-mm@kvack.org>; Thu, 21 May 2009 15:31:01 -0400 (EDT)
Date: Thu, 21 May 2009 12:30:45 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090521193045.GJ10756@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A15A8C7.2030505@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On 15:17 Thu 21 May     , Rik van Riel wrote:
> Sensitive to what?  Allocation failures?
>
> Kidding, I read the rest of your emails.  However,
> chances are whoever runs into the code later on
> will not read everything.
>
> Would GFP_CONFIDENTIAL & PG_confidential be a better
> name, since it indicates the page stores confidential
> information, which should not be leaked?

Definitely, I see your point here and this will be modified in the code.
GFP_CONFIDENTIAL and PG_confidential is more specific and won't raise
any confusion when people read the code or want to use the flags.

Thanks for the input.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
