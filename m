Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0362F5F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 22:02:16 -0400 (EDT)
Date: Sat, 30 May 2009 19:02:14 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
In-Reply-To: <20090530230022.GO6535@oblivion.subreption.com>
Message-ID: <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Sat, 30 May 2009, Larry H. wrote:
> 
> Like I said in the reply to Peter, this is 3 extra bytes for amd64 with
> gcc 4.3.3. I can't be bothered to check other architectures at the
> moment.

.. and I can't be bothered with applying this. I'm just not convinced.

It's 3 extra bytes just for the constant. It's also another test, and 
another branch.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
