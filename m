Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 33DF28D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 18:03:30 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p0HN30eN005506
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 15:03:00 -0800
Received: by iwn40 with SMTP id 40so5437056iwn.14
        for <linux-mm@kvack.org>; Mon, 17 Jan 2011 15:03:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=V1si-+UgmLD+YFzn5cf-x8q=tV_JhHisQUV7z@mail.gmail.com>
References: <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com>
 <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com>
 <1295229722-sup-6494@think> <20110116183000.cc632557.akpm@linux-foundation.org>
 <1295231547-sup-8036@think> <20110117102744.GA27152@csn.ul.ie>
 <1295269009-sup-7646@think> <20110117135059.GB27152@csn.ul.ie>
 <1295272970-sup-6500@think> <1295276272-sup-1788@think> <20110117170907.GC27152@csn.ul.ie>
 <1295285676-sup-8962@think> <AANLkTi=V1si-+UgmLD+YFzn5cf-x8q=tV_JhHisQUV7z@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 17 Jan 2011 15:02:40 -0800
Message-ID: <AANLkTinHBLDw9HRdESK6eMi8Q1ZROgFZvUqwxr-SCuto@mail.gmail.com>
Subject: Re: hunting an IO hang
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 17, 2011 at 10:24 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So right now my plan is:
> =A0- I will revert those two later today and then release -rc1 in the eve=
ning
> UNLESS
> =A0- somebody posts a patch for the problem in the next few hours [..]

Ok, so nothing obvious popped up, and I reverted the two patches.

I've also seen two other patches floating around here in this thread
(one by Andrea, one by Minchan), but didn't apply them as it wasn't
entirely clear what the status of those patches were. My current plan
is to do -rc1 tonight, and hopefully with the two reverts it will be
reasonably stable. We obviously will have several weeks for polishing.

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
