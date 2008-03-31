Date: Mon, 31 Mar 2008 15:04:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/7] mm: introduce VM_MIXEDMAP
Message-Id: <20080331150426.20d57ddb.akpm@linux-foundation.org>
In-Reply-To: <20080328015421.905848000@nick.local0.net>
References: <20080328015238.519230000@nick.local0.net>
	<20080328015421.905848000@nick.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: torvalds@linux-foundation.org, jaredeh@gmail.com, cotte@de.ibm.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Mar 2008 12:52:39 +1100
npiggin@suse.de wrote:

> From: npiggin@suse.de
> From: Jared Hulbert <jaredeh@gmail.com>
> To: akpm@linux-foundation.org
> Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
> Subject: [patch 1/7] mm: introduce VM_MIXEDMAP
> Date: 	Fri, 28 Mar 2008 12:52:39 +1100
> Sender: owner-linux-mm@kvack.org
> User-Agent: quilt/0.46-14

It's unusual to embed the original author's From: line in the headers
like that - it is usually placed in the message body and this arrangement
might fool some people's scripts.

patch 6/7 was subtly hidden, concatenated to 5/7, but I found it.

[7/7] needs to be redone please - git-s390 makes functional changes to
add_shared_memory().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
