Date: Tue, 9 May 2000 08:44:43 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <qwwpuqwp1tv.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.10005090844050.1100-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Daniel Stone <tamriel@ductape.net>, riel@nl.linux.org, Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On 9 May 2000, Christoph Rohland wrote:

> Daniel Stone <tamriel@ductape.net> writes:
> 
> > That's astonishing, I'm sure, but think of us poor bastards who
> > DON'T have an SMP machine with >1gig of RAM.
> 
> He has to care obout us fortunate guys with e.g. 8GB memory also. The
> recent kernels are broken for that also.

Try out the really recent one - pre7-8. So far it hassome good reviews,
and I've tested it both on a 20MB machine and a 512MB one..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
