Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6FF476B0089
	for <linux-mm@kvack.org>; Tue, 21 Dec 2010 02:32:43 -0500 (EST)
Received: by iyj17 with SMTP id 17so3000821iyj.14
        for <linux-mm@kvack.org>; Mon, 20 Dec 2010 23:32:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1012202048220.15447@tigran.mtv.corp.google.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<20101220103307.GA22986@infradead.org>
	<AANLkTikss0RW_xRrD_vVvfqy1rH+NC=WPUB2qKBaw5qo@mail.gmail.com>
	<alpine.LSU.2.00.1012202048220.15447@tigran.mtv.corp.google.com>
Date: Tue, 21 Dec 2010 16:32:41 +0900
Message-ID: <AANLkTimMKjLRiV5dpZL0wJ0FWLJyqQ8oNJbCQt9ZdrHP@mail.gmail.com>
Subject: Re: [RFC 0/5] Change page reference hanlding semantic of page cache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 21, 2010 at 2:07 PM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 21 Dec 2010, Minchan Kim wrote:
>> On Mon, Dec 20, 2010 at 7:33 PM, Christoph Hellwig <hch@infradead.org> w=
rote:
>> > You'll need to merge all patches into one, otherwise you create really
>> > nasty memory leaks when bisecting between them.
>> >
>>
>> Okay. I will resend.
>>
>> Thanks for the notice, Christoph.
>
> Good point from hch, but I feel even more strongly: if you're going to
> do this now, please rename remove_from_page_cache (delete_from_page_cache
> was what I chose back when I misdid it) - you're changing an EXPORTed
> function in a subtle (well, subtlish) confusing way, which could easily
> waste people's time down the line, whether in not-yet-in-tree filesystems
> or backports of fixes. =A0I'd much rather you break someone's build,
> forcing them to look at what changed, than crash or leak at runtime.
>
> If you do rename, you can keep your patch structure, introducing the
> new function as a wrapper to the old at the beginning, then removing
> the old function at the end.

It is very good idea!!
Thanks for good suggestion, Hugh.

>
> (As you know, I do agree that it's right to decrement the reference
> count at the point of removing from page cache.)
>
> Hugh
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
