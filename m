Date: Tue, 5 Jun 2001 17:46:51 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
In-Reply-To: <20010605231454.P26756@redhat.com>
Message-ID: <Pine.LNX.4.21.0106051742590.3541-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, =?iso-8859-1?Q?Andr=E9_Dahlqvist?= <anedah-9@sm.luth.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 5 Jun 2001, Stephen C. Tweedie wrote:

> Hi,
> 
> On Tue, Jun 05, 2001 at 04:48:46PM -0300, Marcelo Tosatti wrote:
>  
> > I'm resending the reapswap patch for inclusion into -ac series. 
> 
> Isn't it broken in this state?  Checking page_count, page->buffers and
> PageSwapCache without the appropriate locks is dangerous.

We hold the pagemap_lru_lock, so there will be no one doing lookups on
this swap page (get_swapcache_page() locks pagemap_lru_lock).

Am I overlooking something here? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
