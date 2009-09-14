Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 678186B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 00:04:29 -0400 (EDT)
Received: by pxi1 with SMTP id 1so2216236pxi.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 21:04:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909131956590.28668@sister.anvils>
References: <200909100215.36350.ngupta@vflare.org>
	 <200909100332.55910.ngupta@vflare.org> <4AAB065D.3070602@vflare.org>
	 <Pine.LNX.4.64.0909131956590.28668@sister.anvils>
Date: Mon, 14 Sep 2009 09:34:29 +0530
Message-ID: <d760cf2d0909132104t703c9420y119e51e3bd2c9aa5@mail.gmail.com>
Subject: Re: [PATCH 0/4] compcache: in-memory compressed swapping v2
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 14, 2009 at 12:37 AM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> On Sat, 12 Sep 2009, Nitin Gupta wrote:
>> On 09/10/2009 03:32 AM, Nitin Gupta wrote:
>> > Project home: http://compcache.googlecode.com/
>> >
>> > * Changelog: v2 vs initial revision
>> > =A0 - Use 'struct page' instead of 32-bit PFNs in ramzswap driver and
>> > =A0 xvmalloc.
>> > =A0 =A0 This is to make these 64-bit safe.
>> > =A0 - xvmalloc is no longer a separate module and does not export any =
symbols.
>> > =A0 =A0 Its compiled directly with ramzswap block driver. This is to a=
void any
>> > =A0 =A0 last bit of confusion with any other allocator.
>> > =A0 - set_swap_free_notify() now accepts block_device as parameter ins=
tead of
>> > =A0 =A0 swp_entry_t (interface cleanup).
>> > =A0 - Fix: Make sure ramzswap disksize matches usable pages in backing=
 swap
>> > =A0 file.
>> > =A0 =A0 This caused initialization error in case backing swap file had
>> > =A0 =A0 intra-page
>> > =A0 =A0 fragmentation.
>>
>> Can anyone please review these patches for possible inclusion in 2.6.32?
>
> Sorry, I certainly wouldn't be able to review them for 2.6.32 myself.
>
> Since we're already in the merge window, and this work has not yet
> had exposure in mmotm (preferably) or linux-next, I really doubt
> anyone should be pushing it for 2.6.32.
>
> I'd be quite glad to see it and experiment with it in mmotm,
> so it could go into 2.6.33 if all okay. =A0And I now fully accept
> that the discard/trim situation is so hazy that you are quite
> right to be asking for your own well-defined notifier instead.
>
> But I'm not going to pretend to have reviewed it.
>

Thanks for the pointer Hugh -- I will try to post patches against mmotm lat=
er.

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
