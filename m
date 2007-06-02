Message-ID: <46619AB6.5060606@goop.org>
Date: Sat, 02 Jun 2007 09:28:38 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC 0/4] CONFIG_STABLE to switch off development checks
References: <20070531002047.702473071@sgi.com> <46603371.50808@goop.org>	 <Pine.LNX.4.64.0706011126030.2284@schroedinger.engr.sgi.com>	 <46606C71.9010008@goop.org> <1180797790.18535.6.camel@kleikamp.austin.ibm.com>
In-Reply-To: <1180797790.18535.6.camel@kleikamp.austin.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Dave Kleikamp wrote:
> I'm on Christoph's side here.  I don't think it makes sense for any code
> to ask to allocate zero bytes of memory and expect valid memory to be
> returned.
>   

Yes, everyone agrees on that.  If you do kmalloc(0), its never OK to
dereference the result.  The question is whether kmalloc(0) should complain.

> Would a compromise be to return a pointer to some known invalid region?
> This way the kmalloc(0) call would appear successful to the caller, but
> any access to the memory would result in an exception.
>   

Yes, that's what Christoph has posted.  I'm slightly concerned about
kmalloc() returning the same non-NULL address multiple times, but it
seems sound otherwise.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
