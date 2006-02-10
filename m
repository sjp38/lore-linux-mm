Date: Fri, 10 Feb 2006 10:03:49 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC] Removing page->flags
In-Reply-To: <aec7e5c30602081835s8870713qa40a6cf88431cad1@mail.gmail.com>
Message-ID: <Pine.LNX.4.63.0602101002430.25390@cuia.boston.redhat.com>
References: <1139381183.22509.186.camel@localhost>  <43E9DBE8.8020900@yahoo.com.au>
 <aec7e5c30602081835s8870713qa40a6cf88431cad1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Feb 2006, Magnus Damm wrote:

> OTOH, maybe it is more likely that a certain struct page is in the cache 
> if struct page would become smaller.

No.  If the struct page is no longer equal to the size of
a cache line, most of the struct page structures will end
up straddling two cache lines, instead of each being on
their own cache line.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
