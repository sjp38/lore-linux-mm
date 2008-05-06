Date: Tue, 6 May 2008 07:19:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc.c: fix a typo
Message-Id: <20080506071943.46641c26.akpm@linux-foundation.org>
In-Reply-To: <482029E7.6070308@cn.fujitsu.com>
References: <4820272C.4060009@cn.fujitsu.com>
	<482027E4.6030300@cn.fujitsu.com>
	<482029E7.6070308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: clameter@sgi.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 06 May 2008 17:50:31 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:

> Li Zefan wrote:
> > ---
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
> 
> Sorry for the noise, but the signed-off was eaten. :(
> Maybe I should leave a blank line before the signed-off.
> 
> ---
> 
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bdd5c43..d0ba10d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -303,7 +303,7 @@ static void destroy_compound_page(struct page *page, unsigned long order)
>  	for (i = 1; i < nr_pages; i++) {
>  		struct page *p = page + i;
>  
> -		if (unlikely(!PageTail(p) |
> +		if (unlikely(!PageTail(p) ||
>  				(p->first_page != page)))
>  			bad_page(page);
>  		__ClearPageTail(p);

I have a vague memory that the "|" was deliberate.  Most of the time,
"!PageTail" will be false so most of the time we won't take the first
branch so it's probably worth omitting it and always doing the pointer
comparison.

It's a somewhat dopey trick and shouldn't have been done without a comment.

otoh maybe it was a typo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
