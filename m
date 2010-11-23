Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B27B6B008C
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 01:05:42 -0500 (EST)
Received: by iwn10 with SMTP id 10so938367iwn.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 22:05:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101122214814.36c209a6.akpm@linux-foundation.org>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<20101122141449.9de58a2c.akpm@linux-foundation.org>
	<AANLkTimk4JL7hDvLWuHjiXGNYxz8GJ_TypWFC=74Xt1Q@mail.gmail.com>
	<20101122210132.be9962c7.akpm@linux-foundation.org>
	<AANLkTin62R1=2P+Sh0YKJ3=KAa6RfLQLKJcn2VEtoZfG@mail.gmail.com>
	<20101122212220.ae26d9a5.akpm@linux-foundation.org>
	<AANLkTinTp2N3_uLEm7nf0=Xu2f9Rjqg9Mjjxw-3YVCcw@mail.gmail.com>
	<20101122214814.36c209a6.akpm@linux-foundation.org>
Date: Tue, 23 Nov 2010 15:05:39 +0900
Message-ID: <AANLkTimpfZuKW-hXjXknn3ESKP81AN3BaXO=qG81Lrae@mail.gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 2:48 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 23 Nov 2010 14:45:15 +0900 Minchan Kim <minchan.kim@gmail.com> wr=
ote:
>
>> On Tue, Nov 23, 2010 at 2:22 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>> > On Tue, 23 Nov 2010 14:23:33 +0900 Minchan Kim <minchan.kim@gmail.com>=
 wrote:
>> >
>> >> On Tue, Nov 23, 2010 at 2:01 PM, Andrew Morton
>> >> <akpm@linux-foundation.org> wrote:
>> >> > On Tue, 23 Nov 2010 13:52:05 +0900 Minchan Kim <minchan.kim@gmail.c=
om> wrote:
>> >> >
>> >> >> >> +/*
>> >> >> >> + * Function used to forecefully demote a page to the head of t=
he inactive
>> >> >> >> + * list.
>> >> >> >> + */
>> >> >> >
>> >> >> > This comment is wrong? __The page gets moved to the _tail_ of th=
e
>> >> >> > inactive list?
>> >> >>
>> >> >> No. I add it in _head_ of the inactive list intentionally.
>> >> >> Why I don't add it to _tail_ is that I don't want to be aggressive=
