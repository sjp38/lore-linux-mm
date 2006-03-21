Subject: Re: [PATCH][8/8] mm: lru interface change
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <441FF007.6020901@yahoo.com.au>
References: <bc56f2f0603200538g3d6aa712i@mail.gmail.com>
	 <441FF007.6020901@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 21 Mar 2006 14:13:05 +0100
Message-Id: <1142946785.3077.78.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Stone Wang <pwstone@gmail.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > +	page->wired_count ++;
> 
> Oh dear, I missed this change you made to struct page, tucked away in 5/8.
> This alone pretty much makes it a showstopper, I'm afraid. You'll have to
> work out some other way to do it so as not to penalise 99.999% of machines
> which don't need this.
> 
> (Oh, and making the field a short usually won't help either, because of
> alignment constraints).

it's not that hard even. All you need to do is make the vm be lazy about
it; if it encounters a pinned page during scanning, move it THEN to the
pinned list. If it then gets pinned more no issue. The first unpin then
moves it back to the normal list (yes it's still pinned), but the first
time the VM sees it it goes right back to the pinned list.
That way there's no need to keep a "pin depth" at all...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
