Date: Wed, 7 Jun 2000 20:58:19 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607205819.E30951@redhat.com>
References: <393E8AEF.7A782FE4@reiser.to> <Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Wed, Jun 07, 2000 at 03:01:22PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Hans Reiser <hans@reiser.to>, "Stephen C. Tweedie" <sct@redhat.com>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 03:01:22PM -0300, Rik van Riel wrote:
> 
> I'd like to be able to keep stuff simple in the shrink_mmap
> "equivalent" I'm working on. Something like:
> 
> if (PageDirty(page) && page->mapping && page->mapping->flush)
> 	maxlaunder -= page->mapping->flush();

That looks ideal.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
