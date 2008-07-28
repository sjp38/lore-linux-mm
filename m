Message-ID: <488D7F79.40102@goop.org>
Date: Mon, 28 Jul 2008 01:12:41 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: How to get a sense of VM pressure
References: <488A1398.7020004@goop.org> <1217230570.6331.6.camel@twins>
In-Reply-To: <1217230570.6331.6.camel@twins>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Virtualization Mailing List <virtualization@lists.osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> Have a peek at this:
>
>   http://people.redhat.com/~riel/riel-OLS2006.pdf
>
> The refault patches have been posted several times, but nobody really
> tried to use them for your problem.
>   

Yep, Rik pointed the paper and patches out to me.  Seems like an 
interesting approach to play with.  The refaulting measure is nice 
because it should give a fairly good idea of how much memory you need to 
add to get the fault rate down below some particular level.  It doesn't 
help with shrinking, other than telling you you've gone too far, and how 
much too far, which is definitely useful to know.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
