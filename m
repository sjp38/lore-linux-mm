Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2DE436B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:43:45 -0400 (EDT)
Received: by vwj42 with SMTP id 42so2454031vwj.12
        for <linux-mm@kvack.org>; Sun, 05 Jul 2009 08:27:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090705151628.GA11307@localhost>
References: <20090705182533.0902.A69D9226@jp.fujitsu.com>
	 <20090705121308.GC5252@localhost>
	 <20090705211739.091D.A69D9226@jp.fujitsu.com>
	 <20090705130200.GA6585@localhost>
	 <2f11576a0907050619t5dea33cfwc46344600c2b17b5@mail.gmail.com>
	 <28c262360907050804p70bc293uc7330a6d968c0486@mail.gmail.com>
	 <20090705151628.GA11307@localhost>
Date: Mon, 6 Jul 2009 00:27:20 +0900
Message-ID: <28c262360907050827y577c3859g5e05e82935e96010@mail.gmail.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 6, 2009 at 12:16 AM, Wu Fengguang<fengguang.wu@intel.com> wrote=
:
> On Sun, Jul 05, 2009 at 11:04:17PM +0800, Minchan Kim wrote:
>> On Sun, Jul 5, 2009 at 10:19 PM, KOSAKI
>> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> >>> > > + printk("%ld total anon pages\n", global_page_state(NR_ANON_PAG=
ES));
>> >>> > > =C2=A0 printk("%ld total pagecache pages\n", global_page_state(N=
R_FILE_PAGES));
>> >>> >
>> >>> > Can we put related items together, ie. this looks more friendly:
>> >>> >
>> >>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 Anon:XXX active_anon:XXX inactive_anon=
:XXX
>> >>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 File:XXX active_file:XXX inactive_file=
:XXX
>> >>>
>> >>> hmmm. Actually NR_ACTIVE_ANON + NR_INACTIVE_ANON !=3D NR_ANON_PAGES.
>> >>> tmpfs pages are accounted as FILE, but it is stay in anon lru.
>> >>
>> >> Right, that's exactly the reason I propose to put them together: to
>> >> make the number of tmpfs pages obvious.
>> >>
>> >>> I think your proposed format easily makes confusion. this format cau=
se to
>> >>> imazine Anon =3D active_anon + inactive_anon.
>> >>
>> >> Yes it may confuse normal users :(
>> >>
>> >>> At least, we need to use another name, I think.
>> >>
>> >> Hmm I find it hard to work out a good name.
>> >>
>> >> But instead, it may be a good idea to explicitly compute the tmpfs
>> >> pages, because the excessive use of tmpfs pages could be a common
>> >> reason of OOM.
>> >
>> > Yeah, =C2=A0explicite tmpfs/shmem accounting is also useful for /proc/=
meminfo.
>>
>> Do we have to account it explicitly?
>
> When OOM happens, one frequent question to ask is: are there too many
> tmpfs/shmem pages? =C2=A0Exporting this number makes our oom-message-deco=
ding
> life easier :)

Indeed.

>> If we know the exact isolate pages of each lru,
>>
>> tmpfs/shmem =3D (NR_ACTIVE_ANON + NR_INACTIVE_ANON + isolate(anon)) -
>> NR_ANON_PAGES.
>>
>> Is there any cases above equation is wrong ?
>
> That's right, but the calculation may be too complex (and boring) for
> our little brain ;)

Yes. if something is change in future or we miss someting, the above
question may be wrong.
I wanted to remove overhead of new accouting.

Anyway, I think it's not a big cost in normal system.
So If you want to add new accounting, I don't have any objection. :)

> Thanks,
> Fengguang
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
