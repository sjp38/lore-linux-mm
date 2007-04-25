Date: Wed, 25 Apr 2007 01:40:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
Message-Id: <20070425014015.c9dd06e9.akpm@linux-foundation.org>
In-Reply-To: <462F0F90.3070600@shadowen.org>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704241320540.13005@schroedinger.engr.sgi.com>
	<20070424132740.e4bdf391.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704241332090.13005@schroedinger.engr.sgi.com>
	<20070424134325.f71460af.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704241351400.13382@schroedinger.engr.sgi.com>
	<20070424141826.952d2d32.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704241429240.13904@schroedinger.engr.sgi.com>
	<20070424143635.cdff71de.akpm@linux-foundation.org>
	<462E7AB6.8000502@shadowen.org>
	<462E9DDC.40700@shadowen.org>
	<1177461251.1281.7.camel@dyn9047017100.beaverton.ibm.com>
	<Pine.LNX.4.64.0704242329060.21213@schroedinger.engr.sgi.com>
	<462F0F90.3070600@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Christoph Lameter <clameter@sgi.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Apr 2007 09:21:36 +0100 Andy Whitcroft <apw@shadowen.org> wrote:

> >  	if (unlikely(nid != numa_node_id())) {
> >  		if (dtor)
> >  			dtor(p);
> > -		free_hot_page(page);
> > +		__free_page(page);
> >  		return;
> >  	}
> 
> Confirmed, this fixes the machine.

OK, thanks guys - another one for the hot-fixes directory.

Do we know where the extra refcount on that page is coming from?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
