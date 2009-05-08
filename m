Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D64C26B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 04:50:37 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id d14so720477and.26
        for <linux-mm@kvack.org>; Fri, 08 May 2009 01:51:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090505212139.GA2559@cmpxchg.org>
References: <20090501181449.GA8912@cmpxchg.org>
	 <1241430874-12667-1-git-send-email-hannes@cmpxchg.org>
	 <20090505122442.6271c7da.akpm@linux-foundation.org>
	 <20090505203807.GB2428@cmpxchg.org>
	 <20090505140517.bef78dd3.akpm@linux-foundation.org>
	 <20090505212139.GA2559@cmpxchg.org>
Date: Fri, 8 May 2009 17:51:24 +0900
Message-ID: <aec7e5c30905080151q5a4f4ebq1e743b534a5fc84a@mail.gmail.com>
Subject: Re: [patch 1/3] mm: introduce follow_pte()
From: Magnus Damm <magnus.damm@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-media@vger.kernel.org, hverkuil@xs4all.nl, lethal@linux-sh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, May 6, 2009 at 6:21 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, May 05, 2009 at 02:05:17PM -0700, Andrew Morton wrote:
>> On Tue, 5 May 2009 22:38:07 +0200
>> Johannes Weiner <hannes@cmpxchg.org> wrote:
>> > On Tue, May 05, 2009 at 12:24:42PM -0700, Andrew Morton wrote:
>> > > On Mon, =A04 May 2009 11:54:32 +0200
>> > > Johannes Weiner <hannes@cmpxchg.org> wrote:
>> > >
>> > > > A generic readonly page table lookup helper to map an address spac=
e
>> > > > and an address from it to a pte.
>> > >
>> > > umm, OK.
>> > >
>> > > Is there actually some point to these three patches? =A0If so, what =
is it?
>> >
>> > Magnus needs to check for physical contiguity of a VMAs backing pages
>> > to support zero-copy exportation of video data to userspace.
>> >
>> > This series implements follow_pfn() so he can walk the VMA backing
>> > pages and ensure their PFNs are in linear order.
>> >
>> > [ This patch can be collapsed with 2/3, I just thought it would be
>> > =A0 easier to read the diffs when having them separate. ]
>> >
>> > 1/3 and 2/3: factor out the page table walk from follow_phys() into
>> > follow_pte().
>> >
>> > 3/3: implement follow_pfn() on top of follow_pte().
>>
>> So we could bundle these patches with Magnus's patchset, or we could
>> consider these three patches as a cleanup or something.
>>
>> Given that 3/3 introduces an unused function, I'm inclined to sit tight
>> and await Magnus's work.
>
> Yeah, I didn't see the video guys responding on Magnus' patch yet, so
> let's wait for them.
>
> Magnus, the actual conversion of your code should be trivial, could
> you respin it on top of these three patches using follow_pfn() then?

So I tested the patches in -mm (1/3, 2/3, 3/3) together with the zero
copy patch and everything seems fine. Feel free to add acks from me,
least for patch 1/3 and 3/3 - i know too little about the generic case
to say anything about 2/3.

Acked-by: Magnus Damm <damm@igel.co.jp>

I'll send V3 of my zero copy patch in a little while. Thanks a lot for the =
help!

Cheers,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
