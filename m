Subject: Re: Subtle MM bug
References: <Pine.LNX.4.31.0101171546130.5464-100000@localhost.localdomain>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 17 Jan 2001 19:53:31 +0100
In-Reply-To: Rik van Riel's message of "Wed, 17 Jan 2001 15:48:39 +1100 (EST)"
Message-ID: <87wvburowk.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> > Second test: kernel compile make -j32 (empirically this puts the
> > VM under load, but not excessively!)
> >
> > 2.2.17 -> make -j32  392.49s user 47.87s system 168% cpu 4:21.13 total
> > 2.4.0  -> make -j32  389.59s user 31.29s system 182% cpu 3:50.24 total
> >
> > Now, is this great news or what, 2.4.0 is definitely faster.
> 
> One problem is that these tasks may be waiting on kswapd when
> kswapd might not get scheduled in on time. On the one hand this
> will mean lower load and less thrashing, on the other hand it
> means more IO wait.
> 

Hm, if all tasks are waiting for memory, what is stopping kswapd to
run? :)
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
