Date: Thu, 22 Jun 2000 21:48:19 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] RSS guarantees and limits
Message-ID: <20000622214819.C28360@pcep-jamie.cern.ch>
References: <85256906.0059E21B.00@D51MTA03.pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <85256906.0059E21B.00@D51MTA03.pok.ibm.com>; from frankeh@us.ibm.com on Thu, Jun 22, 2000 at 12:22:55PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frankeh@us.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

frankeh@us.ibm.com wrote:
> Now I understand this much better. The RSS guarantee is a function of the
> refault-rate <clever>.
> This in principle implements a decay of the limit based on usage.... I like
> that approach.

Be careful with refault rate.  If a process is unable to progress
because of memory pressure, it will have a low refault rate even though
it's _trying_ to fault in lots of pages at high speed.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
