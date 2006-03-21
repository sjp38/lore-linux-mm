Message-ID: <441FF069.4030508@yahoo.com.au>
Date: Tue, 21 Mar 2006 23:24:09 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced
 mlock-LRU semantic
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>	 <1142862078.3114.47.camel@laptopd505.fenrus.org> <5c49b0ed0603201552j58150a18lbf4d0a9b0406d175@mail.gmail.com>
In-Reply-To: <5c49b0ed0603201552j58150a18lbf4d0a9b0406d175@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nate Diller <nate.diller@gmail.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Stone Wang <pwstone@gmail.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nate Diller wrote:

> Might I suggest calling it the long_term_pinned list?  It also might
> be worth putting ramdisk pages on this list, since they cannot be
> written out in response to memory pressure.  This would eliminate the
> need for AOP_WRITEPAGE_ACTIVATE.
> 

They are for the ram filesystem, btw. and I don't think you can eliminate
AOP_WRITEPAGE_ACTIVATE, because it is needed for a number of reasons (out
of swap space being one).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
