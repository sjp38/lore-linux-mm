Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F231E6B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 12:49:45 -0400 (EDT)
Received: by vwj42 with SMTP id 42so2389143vwj.12
        for <linux-mm@kvack.org>; Sun, 05 Jul 2009 06:19:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090705130200.GA6585@localhost>
References: <20090705182533.0902.A69D9226@jp.fujitsu.com>
	 <20090705121308.GC5252@localhost>
	 <20090705211739.091D.A69D9226@jp.fujitsu.com>
	 <20090705130200.GA6585@localhost>
Date: Sun, 5 Jul 2009 22:19:47 +0900
Message-ID: <2f11576a0907050619t5dea33cfwc46344600c2b17b5@mail.gmail.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

>> > > + printk("%ld total anon pages\n", global_page_state(NR_ANON_PAGES))=
;
>> > > =A0 printk("%ld total pagecache pages\n", global_page_state(NR_FILE_=
PAGES));
>> >
>> > Can we put related items together, ie. this looks more friendly:
>> >
>> > =A0 =A0 =A0 =A0 Anon:XXX active_anon:XXX inactive_anon:XXX
>> > =A0 =A0 =A0 =A0 File:XXX active_file:XXX inactive_file:XXX
>>
>> hmmm. Actually NR_ACTIVE_ANON + NR_INACTIVE_ANON !=3D NR_ANON_PAGES.
>> tmpfs pages are accounted as FILE, but it is stay in anon lru.
>
> Right, that's exactly the reason I propose to put them together: to
> make the number of tmpfs pages obvious.
>
>> I think your proposed format easily makes confusion. this format cause t=
o
>> imazine Anon =3D active_anon + inactive_anon.
>
> Yes it may confuse normal users :(
>
>> At least, we need to use another name, I think.
>
> Hmm I find it hard to work out a good name.
>
> But instead, it may be a good idea to explicitly compute the tmpfs
> pages, because the excessive use of tmpfs pages could be a common
> reason of OOM.

Yeah,  explicite tmpfs/shmem accounting is also useful for /proc/meminfo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
