From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14185.34250.163041.796165@dukat.scot.redhat.com>
Date: Fri, 18 Jun 1999 00:33:30 +0100 (BST)
Subject: Re: filecache/swapcache questions
In-Reply-To: <Pine.LNX.4.05.9906150930310.13631-100000@humbolt.nl.linux.org>
References: <199906150716.AAA88552@google.engr.sgi.com>
	<Pine.LNX.4.05.9906150930310.13631-100000@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 15 Jun 1999 09:32:19 +0200 (CEST), Rik van Riel
<riel@nl.linux.org> said:

>> How will it be possible for a page to be in the swapcache, for its
>> reference count to be 1 (which has been checked just before), and for
>> its swap_count(page->offset) to also be 1? I can see this being
>> possible only if an unmap/exit path might lazily leave a anonymous
>> page in the swap cache, but I don't believe that happens.

> It does happen. We use a 'two-stage' reclamation process instead
> of page aging. It seems to work wonderfully -- nice page aging
> properties without the overhead. 

Much more than that: if we take a write fault to a page which is shared
on swap by two processes, then we bring it into cache and take a
copy-on-write, leaving one copy in the swap cache (reference one: it is
_only_ in use by the swap cache now), and the other copy being reference
by the faulting process.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
