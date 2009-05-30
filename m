Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 411DE5F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 18:29:17 -0400 (EDT)
Date: Sat, 30 May 2009 15:29:39 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
In-Reply-To: <20090530192829.GK6535@oblivion.subreption.com>
Message-ID: <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Sat, 30 May 2009, Larry H. wrote:
> 
> The ZERO_OR_NULL_PTR macro is changed accordingly. This patch does
> not modify its behavior nor has any performance nor functionality
> impact.

I'm sure it makes a code generation difference, with (a) big constants and 
(b) no longer possible to merge the conditional into one single one.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
