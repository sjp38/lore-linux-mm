Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 30FCA6B0069
	for <linux-mm@kvack.org>; Sat,  4 Oct 2014 13:05:22 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id h18so780831igc.0
        for <linux-mm@kvack.org>; Sat, 04 Oct 2014 10:05:21 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id n6si23004477icc.3.2014.10.04.10.05.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 04 Oct 2014 10:05:21 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id at20so1347775iec.12
        for <linux-mm@kvack.org>; Sat, 04 Oct 2014 10:05:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABe+QzA-E40bFFXYJBc663Kx0KrE3xy2uZq5xOH2XL6mFPA6+w@mail.gmail.com>
References: <CABe+QzA=0YVpQ8rN+3X-cbH6JP1nWTvp2spb93P9PqJhmjBROA@mail.gmail.com>
	<CABe+QzA-E40bFFXYJBc663Kx0KrE3xy2uZq5xOH2XL6mFPA6+w@mail.gmail.com>
Date: Sat, 4 Oct 2014 10:05:20 -0700
Message-ID: <CABe+QzCn_7xm1x62o5d2VoiQrf_7LorhnVOD905Zzd+uu_EuqQ@mail.gmail.com>
Subject: Kswapd 100% CPU since 3.8 on Sandybridge
From: Sarah A Sharp <sarah@thesharps.us>
Content-Type: multipart/alternative; boundary=90e6ba614f0cc782f205049bdaf3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, intel-gfx@lists.freedesktop.org

--90e6ba614f0cc782f205049bdaf3
Content-Type: text/plain; charset=UTF-8

Please excuse the non-wrapped email. My personal system is currently
b0rked, so I'm sending this in frustration from my phone.

My laptop is currently completely hosed. Disk light on full solid
Mouse movement sluggish to the point of moving a couple cms per second.
Firefox window greyed out but not OOM killed yet. When this behavior
occurred in the past, if I ran top, I would see kswapd taking up 100% of
one of my two CPUs.

If I can catch the system in time before mouse movement becomes too
sluggish, closing the browser window will cause kswapd usage to drop, and
the system goes back to a normal state. If I don't catch it in time, I
can't even ssh into the box to kill Firefox because the login times out.
Occasionally Firefox gets OOM killed, but most of the time I have to use
sysreq keys to reboot the system.

This can be reproduced by using either Chrome or Firefox. Chrome fails
faster. I'm not sure whether it's related to loading tabs with a bunch of
images, maybe flash, but it takes around 10-15 tabs being open before it
starts to fail. I can try to characterize it further.

System: Lenovo x220 Intel Sandy Bridge graphics
Ubuntu 14.04 with edgers PPA for Mesa
3.16.3 kernel

Since around the 3.8 kernel time frame, I've been able to reproduce this
behavior. I'm pretty sure it was a kernel change.

I mentioned this to Mel Gorman at LinuxCon NA, and he wanted me to run a
particular mm test. I still don't have time to triage this, but I'm now
frustrated enough to make time.

Mel, what test do you want me to run?

Sarah Sharp

--90e6ba614f0cc782f205049bdaf3
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Please excuse the non-wrapped email. My personal system is c=
urrently b0rked, so I&#39;m sending this in frustration from my phone.</p>
<p dir=3D"ltr">My laptop is currently completely hosed. Disk light on full =
solid<br>
 Mouse movement sluggish to the point of moving a couple cms per second. Fi=
refox window greyed out but not OOM killed yet. When this behavior occurred=
 in the past, if I ran top, I would see kswapd taking up 100% of one of my =
two CPUs.</p>
<p dir=3D"ltr">If I can catch the system in time before mouse movement beco=
mes too sluggish, closing the browser window will cause kswapd usage to dro=
p, and the system goes back to a normal state. If I don&#39;t catch it in t=
ime, I can&#39;t even ssh into the box to kill Firefox because the login ti=
mes out. Occasionally Firefox gets OOM killed, but most of the time I have =
to use sysreq keys to reboot the system.</p>
<p dir=3D"ltr">This can be reproduced by using either Chrome or Firefox. Ch=
rome fails faster. I&#39;m not sure whether it&#39;s related to loading tab=
s with a bunch of images, maybe flash, but it takes around 10-15 tabs being=
 open before it starts to fail. I can try to characterize it further.</p>
<p dir=3D"ltr">System: Lenovo x220 Intel Sandy Bridge graphics<br>
Ubuntu 14.04 with edgers PPA for Mesa<br>
3.16.3 kernel</p>
<p dir=3D"ltr">Since around the 3.8 kernel time frame, I&#39;ve been able t=
o reproduce this behavior. I&#39;m pretty sure it was a kernel change.</p>
<p dir=3D"ltr">I mentioned this to Mel Gorman at LinuxCon NA, and he wanted=
 me to run a particular mm test. I still don&#39;t have time to triage this=
, but I&#39;m now frustrated enough to make time.</p>
<p dir=3D"ltr">Mel, what test do you want me to run?</p>
<p dir=3D"ltr">Sarah Sharp</p>

--90e6ba614f0cc782f205049bdaf3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
