Received: by rv-out-0708.google.com with SMTP id f25so791326rvb.26
        for <linux-mm@kvack.org>; Fri, 08 Aug 2008 02:22:29 -0700 (PDT)
Message-ID: <38b2ab8a0808080222h6d810b7fheefaf3633e65ea8a@mail.gmail.com>
Date: Fri, 8 Aug 2008 11:22:29 +0200
From: "Francis Moreau" <francis.moro@gmail.com>
Subject: Re: question about do_anonymous_page()
In-Reply-To: <Pine.LNX.4.64.0808080938001.15941@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <38b2ab8a0808080101v795327f0n9da5adb33a3c1a9@mail.gmail.com>
	 <38b2ab8a0808080123t5083dc17qa250bd02c753f80d@mail.gmail.com>
	 <Pine.LNX.4.64.0808080938001.15941@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 8, 2008 at 10:51 AM, Hugh Dickins <hugh@veritas.com> wrote:
>> Is it simply because lru_add_active() doesn't exist ?
>
> Yes.
>

great at least one thing I understood from the kernel mm internals ;)

> It just happens that whoever (Rik?) originally named that function was
> primarily thinking of the page cache at the time; or perhaps wasn't
> thinking of the file page cache at all, just regarding all the pages
> we put on that list as cached in some sense.
>

I think it might be the second reason since the page is not directly
added to the LRU
but to a pagevec structure since the term 'cache'. But IMHO if so,
it's just confusing and
lru_cache_add_active() shouldn't contain implemantation details in its name.

> You're right that it's a little anomalous, but nothing to worry about.

well, it's just that I got confusing when reading the code for the
first time. I really have hard
time to understand it...

> I get more bothered by page_cache_get(), which is and always(?) has
> been the same thing as get_page(): sometimes we use one, sometimes
> the other, and often we use page_cache_get() on anonymous pages.
>

Yes and this is what confused me: lru_cache_add_active() does call
page_cache_get()
for anymous pages, hence my question.


Thanks !
-- 
Francis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
