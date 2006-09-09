Date: Sat, 9 Sep 2006 23:05:33 +0200 (CEST)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [patch 1/2] own header file for struct page.
In-Reply-To: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com>
Message-ID: <Pine.LNX.4.64.0609092248400.6762@scrub.home>
References: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 8 Sep 2006, Heiko Carstens wrote:

> In order to get of all these problems caused by macros it seems to
> be a good idea to get rid of them and convert them to static inline
> functions. Because of header file include order it's necessary to have a
> seperate header file for the struct page definition.
> 
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
> 
> Patches are against git tree as of today. Better ideas welcome of course.
> 
>  include/linux/mm.h   |   64 --------------------------------------------
>  include/linux/page.h |   74 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 75 insertions(+), 63 deletions(-)

To avoid the explosion in number of small header files each containing a 
single definition, it would be better to generally split between the 
definitions and implementations, so IMO mm_types.h with all the structures 
and defines from mm.h would be better.

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
