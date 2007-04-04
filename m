Subject: Re: [PATCH 11/14] get_unmapped_area handles MAP_FIXED on ramfs
	(nommu)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <23091.1175681818@redhat.com>
References: <20070404040231.A110CDDEB8@ozlabs.org>
	 <23091.1175681818@redhat.com>
Content-Type: text/plain
Date: Thu, 05 Apr 2007 09:13:52 +1000
Message-Id: <1175728433.30879.79.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 11:16 +0100, David Howells wrote:
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > -	if (!(flags & MAP_SHARED))
> > +	/* Deal with MAP_FIXED differently ? Forbid it ? Need help from some nommu
> > +	 * folks there... --BenH.
> > +	 */
> > +	if ((flags & MAP_FIXED) || !(flags & MAP_SHARED))
> 
> MAP_FIXED on NOMMU?  Surely you jest...

Heh, see the comment, I was actually wondering about it :-)

> See the first if-statement in validate_mmap_request().
> 
> If anything, you should be adding BUG_ON(flags & MAP_FIXED).

Yeah, I missed that bit. That will simplify the problem.

Thanks,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
