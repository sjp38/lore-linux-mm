Date: Thu, 6 Jun 2002 14:29:18 +1000 (EST)
From: Michael Chapman <mchapman@beren.hn.org>
Reply-To: Michael Chapman <mchapman@student.usyd.edu.au>
Subject: Re: Oops in pte_chain_alloc (rmap 12h applied to vanilla 2.4.18)
 (fwd)
In-Reply-To: <a05101000b924379fdff3@[192.168.239.105]>
Message-ID: <Pine.LNX.4.44.0206061424190.1337-100000@beren.hn.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 Jun 2002, Jonathan Morton wrote:
> >I compiled this kernel with gcc 2.96.
> 
> I understood you weren't supposed to do that.  Try 2.95.3.

OK, I've now tried that. It still crashes on the same line of code.

Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
