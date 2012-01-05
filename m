Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B68396B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 11:14:05 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and
 related changes in MM
Date: Thu, 5 Jan 2012 16:13:27 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045545E5@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <20120104195612.GB19181@suse.de>
 <84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLEdTMB6JtYViRJq5gZ4_w5aaV18S3q-1rOXGzaMtmiW6A@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB9826904554391@008-AM1MPN1-003.mgdnok.nokia.com>
 <20120105145753.GA3937@suse.de>
In-Reply-To: <20120105145753.GA3937@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

-----Original Message-----
From: ext Greg KH [mailto:gregkh@suse.de]=20
>No, please listen to what people, including me, are saying, otherwise your=
 code will be totally ignored.

I tried to sort out all inputs coming. But before doing the next step I pre=
fer to have tests passed. Changes you proposed are strain forward and under=
standable.=20
Hooking in mm/vmscan.c and mm/page-writeback.c is not so easy, I need to fi=
nd proper place and make adequate proposal.
Using memcg is doesn't not look for me now as a good way because I wouldn't=
 like to change memory accounting - memcg has strong reason to keep caches.

Best Wishes,
Leonid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
