Subject: Re: [PATCH 12/14] get_unmapped_area handles MAP_FIXED in /dev/mem
	(nommu)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <23349.1175682669@redhat.com>
References: <20070404040232.2FEF6DDEBA@ozlabs.org>
	 <23349.1175682669@redhat.com>
Content-Type: text/plain
Date: Thu, 05 Apr 2007 09:14:12 +1000
Message-Id: <1175728452.30879.81.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 11:31 +0100, David Howells wrote:
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > +	if (flags & MAP_FIXED)
> > +		if ((addr >> PAGE_SHIFT) != pgoff)
> > +			return (unsigned long) -EINVAL;
> 
> Again... in NOMMU-mode there is no MAP_FIXED - it's rejected before we get
> this far.
> 
> > -	return pgoff;
> > +	return pgoff << PAGE_SHIFT;
> 
> That, however, does appear to be a genuine bugfix.

I'll separate it from the rest of the patches

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
