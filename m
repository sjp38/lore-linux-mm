Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 88CB06B005A
	for <linux-mm@kvack.org>; Thu, 28 May 2009 08:56:43 -0400 (EDT)
Date: Thu, 28 May 2009 05:55:38 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090528125537.GD29711@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <20090528124840.GB1421@ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528124840.GB1421@ucw.cz>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Pavel,

> This should not be configurable. Runtime config, defaulting to
> 'sanitize' may make some sense, but... better just be secure.

We've since moved to an unconditional page sanitization approach,
enabled via boot option. Check out the latest patches in the thread,
don't bother checking the initial page flag ones since there's no
intention to follow that path for now.

Thanks for taking a look.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
