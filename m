Subject: Re: Is Linux kernel 2.2.x Pageable?
References: <Pine.LNX.4.21.0004040826030.16987-100000@duckman.conectiva> <38EDDB4D.F2C210B1@irisa.fr>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 07 Apr 2000 09:48:07 -0500
In-Reply-To: Renaud Lottiaux's message of "Fri, 07 Apr 2000 14:57:49 +0200"
Message-ID: <m1zor6ufvc.fsf@flinx.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Renaud Lottiaux <Renaud.Lottiaux@irisa.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Renaud Lottiaux <Renaud.Lottiaux@irisa.fr> writes:

> Rik van Riel wrote:
> > 
> > On Tue, 4 Apr 2000 pnilesh@in.ibm.com wrote:
> > 
> > > Is Linux kernel 2.2.x pageable ?
> > >
> > > Is Linux kernel 2.3.x pageable ?
> > 
> > no
> 
> May you be a bit more specific about this ?
> Can not any part of the kernel be swapped ? Even Modules ?
> Why ? Just an implementation problem or a deeper reason ?

Modules can be removed.
Pageable kernels are stupid, slow, & dangerous.

If you need a pageable kernel you have other problems.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
