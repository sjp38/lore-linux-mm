Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 58E756B0087
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 11:53:11 -0400 (EDT)
Received: by ywh28 with SMTP id 28so8894854ywh.11
        for <linux-mm@kvack.org>; Wed, 30 Sep 2009 09:07:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090930130815.GA4134@cmpxchg.org>
References: <4AB9A0D6.1090004@crca.org.au> <Pine.LNX.4.64.0909232056020.3360@sister.anvils>
	<4ABC7FBC.4050409@crca.org.au> <20090930120202.GB1412@ucw.cz>
	<20090930130815.GA4134@cmpxchg.org>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Wed, 30 Sep 2009 12:06:58 -0400
Message-ID: <8bd0f97a0909300906k283e3fd2q80705dbf78588cac@mail.gmail.com>
Subject: Re: swsusp on nommu, was 'Re: No more bits in vm_area_struct's
	vm_flags.'
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <ncunningham@crca.org.au>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 30, 2009 at 09:08, Johannes Weiner wrote:
> On Wed, Sep 30, 2009 at 02:02:03PM +0200, Pavel Machek wrote:
>> > > Does TuxOnIce rely on CONFIG_MMU? =C2=A0If so, then the TuxOnIce pat=
ch
>> > > could presumably reuse VM_MAPPED_COPY for now - but don't be
>> > > surprised if that's one we clean away later on.
>> >
>> > Hmm. I'm not sure. The requirements are the same as for swsusp and
>> > uswsusp. Is there some tool to graph config dependencies?
>>
>> I don't think swsusp was ported on any -nommu architecture, so config
>> dependency on MMU should be ok. OTOH such port should be doable...
>
> I am sitting on some dusty patches to split swapfile handling from
> actual paging and implement swsusp on blackfin. =C2=A0They are incomplete
> and I only occasionally find the time to continue working on them. =C2=A0=
If
> somebody is interested or also working on it, please let me know.

suspend to ram works on Blackfin systems w/out a problem, and i cant
think of a reason off the top of my head as to why saving/restoring
the image to disk couldnt work w/out a mmu ...

last time we looked, we found it too coupled to mmu code and we didnt
have a lot of pressure to get it done, so we moved on to other things.
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
