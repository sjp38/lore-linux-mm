Subject: Re: [PATCH] ramfs fixes
References: <20000619182802.B22551@tweedle.linuxcare.com.au>
	<Pine.LNX.4.21.0006191059080.13200-100000@duckman.distro.conectiva>
	<20000620132019.A28309@tweedle.linuxcare.com.au>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: David Gibson's message of "Tue, 20 Jun 2000 13:20:19 +1000"
Date: 20 Jun 2000 13:57:36 +0200
Message-ID: <yttd7lco98v.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <dgibson@linuxcare.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-fsdevel@vger.rutgers.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "david" == David Gibson <dgibson@linuxcare.com> writes:

Hi

david> This actually went in somewhat recently, in 2.3.99pre something (where
david> something is around 4 IIRC). This fixed a bug in ramfs, since
david> previously the dirty bit was never being cleared.

david> At the time ramfs was the *only* place using PG_dirty - it looked like
david> it was just a misleading name for something analagous to BH_protected.

david> Obviously that's not true any more. What does the PG_dirty bit mean
david> these days?

It means that the page is Dirty??? :)))))
Seriosly, now we can have dirty swap cache pages and soon dirty page
cache pages, coming from mmaped files, not only pages from Ramfs have
that bit set.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
