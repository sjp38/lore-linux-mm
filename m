Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 934CC8D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 18:13:35 -0500 (EST)
Received: by iyj17 with SMTP id 17so5314271iyj.14
        for <linux-mm@kvack.org>; Mon, 17 Jan 2011 15:13:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTinHBLDw9HRdESK6eMi8Q1ZROgFZvUqwxr-SCuto@mail.gmail.com>
References: <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com>
	<AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com>
	<1295229722-sup-6494@think>
	<20110116183000.cc632557.akpm@linux-foundation.org>
	<1295231547-sup-8036@think>
	<20110117102744.GA27152@csn.ul.ie>
	<1295269009-sup-7646@think>
	<20110117135059.GB27152@csn.ul.ie>
	<1295272970-sup-6500@think>
	<1295276272-sup-1788@think>
	<20110117170907.GC27152@csn.ul.ie>
	<1295285676-sup-8962@think>
	<AANLkTi=V1si-+UgmLD+YFzn5cf-x8q=tV_JhHisQUV7z@mail.gmail.com>
	<AANLkTinHBLDw9HRdESK6eMi8Q1ZROgFZvUqwxr-SCuto@mail.gmail.com>
Date: Tue, 18 Jan 2011 08:13:33 +0900
Message-ID: <AANLkTinkAwyDGLhmnbntGa=pO_nn-_pdiKMWaryX7nrF@mail.gmail.com>
Subject: Re: hunting an IO hang
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 18, 2011 at 8:02 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Jan 17, 2011 at 10:24 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> So right now my plan is:
>> =A0- I will revert those two later today and then release -rc1 in the ev=
ening
>> UNLESS
>> =A0- somebody posts a patch for the problem in the next few hours [..]
>
> Ok, so nothing obvious popped up, and I reverted the two patches.
>
> I've also seen two other patches floating around here in this thread
> (one by Andrea, one by Minchan), but didn't apply them as it wasn't
> entirely clear what the status of those patches were. My current plan
> is to do -rc1 tonight, and hopefully with the two reverts it will be
> reasonably stable. We obviously will have several weeks for polishing.

Andrea patch fixes memory leak(except compaction) and my one's fixes
page corruption when memory-failure happens on hugepage(It's very rare
case).  It is apparent but not critical if we consider current
status(sooner or later, you should release rc1). So I will resend it
after rc1 release.

Thanks.

>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Linus
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
