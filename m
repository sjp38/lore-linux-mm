Date: Wed, 13 Nov 2002 22:42:11 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] remove hugetlb syscalls
In-Reply-To: <20021113184555.B10889@redhat.com>
Message-ID: <Pine.LNX.4.44L.0211132239370.3817-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Nov 2002, Benjamin LaHaise wrote:

> Since the functionality of the hugetlb syscalls is now available via
> hugetlbfs with better control over permissions, could you apply the
> following patch that gets rid of a lot of duplicate and unnescessary
> code by removing the two hugetlb syscalls?

#include <massive_applause.h>

Yes, lets get rid of this ugliness before somebody actually
finds a way to use these syscalls...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
