Received: by uproxy.gmail.com with SMTP id q2so636737uge
        for <linux-mm@kvack.org>; Mon, 20 Mar 2006 21:23:06 -0800 (PST)
Message-ID: <bc56f2f0603202123o1f43132u@mail.gmail.com>
Date: Tue, 21 Mar 2006 00:23:06 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced mlock-LRU semantic
In-Reply-To: <Pine.LNX.4.64.0603200923560.24138@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
	 <Pine.LNX.4.64.0603200923560.24138@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I will check and fix it.

2006/3/20, Christoph Lameter <clameter@sgi.com>:
> On Mon, 20 Mar 2006, Stone Wang wrote:
>
> > 2. More consistent LRU semantics in Memory Management.
> >    Mlocked pages is placed on a separate LRU list: Wired List.
> >    The pages dont take part in LRU algorithms,for they could never be swapped,
> >    until munlocked.
>
> This also implies that dirty bits of the pte for mlocked pages are never
> checked.
>
> Currently light swapping (which is very common) will scan over all pages
> and move the dirty bits from the pte into struct page. This may take
> awhile but at least at some point we will write out dirtied pages.
>
> The result of not scanning mlocked pages will be that mmapped files will
> not be updated unless either the process terminates or msync() is called.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
