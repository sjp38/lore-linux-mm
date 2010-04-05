Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8265E6B0212
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 20:36:01 -0400 (EDT)
Received: by pwi2 with SMTP id 2so2497929pwi.14
        for <linux-mm@kvack.org>; Sun, 04 Apr 2010 17:36:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100404181550.GA2350@ioremap.net>
References: <alpine.LFD.2.00.1004041125350.5617@localhost>
	 <1270396784.1814.92.camel@barrios-desktop>
	 <20100404160328.GA30540@ioremap.net>
	 <1270398112.1814.114.camel@barrios-desktop>
	 <20100404181550.GA2350@ioremap.net>
Date: Mon, 5 Apr 2010 09:36:00 +0900
Message-ID: <t2z28c262361004041736w61b066efr29557741424e158e@mail.gmail.com>
Subject: Re: why are some low-level MM routines being exported?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Cc: "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org, Joern Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 5, 2010 at 3:15 AM, Evgeniy Polyakov <zbr@ioremap.net> wrote:
> On Mon, Apr 05, 2010 at 01:21:52AM +0900, Minchan Kim (minchan.kim@gmail.com) wrote:
>> > > It is added by 18bc0bbd162e3 for pohmelfs and now used by logfs, too.
>> > > I didn't noticed that at that time.
>> > > With git log, any mm guys didn't add Signed-off-by or Reviewed-by.
>> > >
>> > > I think it's not good for file system or module to use it directly.
>> > > It would make LRU management harder.
>> >
>> > How come?
>>
>> What I have a concern is that if file systems or some modules start to
>> overuse it to manage pages LRU directly, some mistake of them would make
>> system global LRU stupid and make system wrong.
>
> All filesystems already call it through find_or_create_page() or
> grab_page() invoked via read path. In some cases fs has more than
> one page grabbed via its internal path where data to be read is
> already placed, so it may want just to add those pages into mm lru.
>

I understood why it does need that in pohmelfs.
AFAIU, other file system using general functions(ex, mpage_readpages or
read_cache_pages) don't need direct LRU handling since it's hided.
But pohmelfs doesn't use general functions.

Isn't pagevec_lru_add_file enough like other file system(ex, nfs, cifs)?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
