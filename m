Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id B728B6B00C3
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:29:13 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH v2 2/2] Memory notification pseudo-device module
Date: Tue, 17 Jan 2012 14:28:28 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045593DE@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
	<5b429d6c4d0a3ad06ec01193eab7edc98a03e0de.1326803859.git.leonid.moiseichuk@nokia.com>
	<CAOJsxLFCbF8azY48_SHhYQ0oRDrf2-rEvGMKHBne2Znpj0XL4g@mail.gmail.com>
	<84FF21A720B0874AA94B46D76DB9826904559397@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLEtuzEYVUtukrA1JeJnuOJ6OsOHOj=j2gs=-0NHYVPzLQ@mail.gmail.com>
In-Reply-To: <CAOJsxLEtuzEYVUtukrA1JeJnuOJ6OsOHOj=j2gs=-0NHYVPzLQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

> -----Original Message-----
> From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext
> Pekka Enberg
> Sent: 17 January, 2012 15:59
...
> If you're serious about making this a generic thing, it must live in
> mm/mem_notify.c. No ifs or buts about it.
> I'm also not completely convinced we need to put memnotify policy in the
> kernel. Why can't we extend Minchan's patch to report the relevant
> numbers and let the userspace figure out when pressure is above some
> interesting threshold?

I do not insist to have it as a part mm, but if you have 1-2-3 items what s=
hould be done in this or Minchan's patch I can participate.
>From my point of view Minchan's patch is not ideal due to required:
1. depends on cgroups (at least as I see it from patch in shrink_mem_cgroup=
_zone()part)
2. reports only memory pressure based on relation in between free and file =
pages which is means by active file IO you may get lowmem=20
3. swapping should not produce lowmem, but active swapping - must, is  it c=
hecked there?
+	if (nr[LRU_INACTIVE_ANON])
+		low_mem =3D true;
4. required changes in vmscan

I think, due to everyone based on his experience/working area profile has o=
wn understanding what is "low memory"  (or similar situation which needs to=
 be tracked)=20
it should be  some generic or extendable API, not like ON/OFF trigger for s=
omething happened inside VM. From another point of view it should not be to=
o generic due=20
to tasks could be solved using memcg, ionice, OOM killer or variations of s=
oft-OOM-patches.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
