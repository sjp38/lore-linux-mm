Date: Mon, 8 Aug 2005 14:54:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Message-Id: <20050808145430.15394c3c.akpm@osdl.org>
In-Reply-To: <200508090724.30962.phillips@arcor.de>
References: <42F57FCA.9040805@yahoo.com.au>
	<200508090710.00637.phillips@arcor.de>
	<200508090724.30962.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com, torvalds@osdl.org, andrea@suse.de, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@arcor.de> wrote:
>
> 'Scuse me:
> 
> On Tuesday 09 August 2005 07:09, Daniel Phillips wrote:
> > Suggestion for your next act:
> 
> ...kill PG_checked please :)  Or at least keep it from spreading.
> 

It already spread - ext3 is using it and I think reiser4.  I thought I had
a patch to rename it to PG_misc1 or somesuch, but no.  It's mandate becomes
"filesystem-specific page flag".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
