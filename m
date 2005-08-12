From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
Date: Fri, 12 Aug 2005 12:34:13 +1000
References: <20050810234246.GT4006@stusta.de> <200508110823.53593.phillips@arcor.de> <27057.1123753592@warthog.cambridge.redhat.com>
In-Reply-To: <27057.1123753592@warthog.cambridge.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508121234.13951.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thursday 11 August 2005 19:46, David Howells wrote:
> Adrian Bunk <bunk@stusta.de> wrote:
> > Since this was done only for CacheFS, and Andrew dropped CacheFS from
> > -mm he could drop this patch as well.
>
> I asked him not to. Somewhat at his instigation, I requested that he drop
> the filesystem caching patches for the moment. I'm updating them and
> they'll be back soon. Taking out this and the other remaining patch means
> he'll just be given them back again shortly.
>
> I know you want to ruthlessly trim out anything that isn't used, but please
> be patient:-)

Are you sure CacheFS is even the right way to do client-side caching?  What is 
wrong with handling the backing store directly in your network filesystem?  
You have to hack your filesystem to use CacheFS anyway, so why not write some 
library functions to handle the backing store mapping and turn the hack into 
a few library calls instead?

I just don't see how turning this functionality into a filesystem is the right 
abstraction.  What actual advantage is there?  I noticed somebody out there 
on the web waxing poetic about how the administrator can look into the cache, 
see what is cached, and even delete some of it.  That just makes me cringe.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
