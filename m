Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0E18D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:51:03 -0400 (EDT)
Received: by ywa1 with SMTP id 1so978645ywa.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 10:51:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
References: <20110424202158.45578f31@neptune.home>
	<20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
	<20110425111705.786ef0c5@neptune.home>
	<BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
Date: Mon, 25 Apr 2011 20:51:01 +0300
Message-ID: <BANLkTikSEg-+4==08FSTpPsRKOxW-o7ftg@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>

On Mon, Apr 25, 2011 at 6:22 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> (Pekka? This is a real _problem_. The whole "confused debugging" is
> wasting a lot of peoples time. Can we please try to get slabinfo
> statistics work right for the merged state. Or perhaps decide to just
> not merge at all?)

I sent proof of concept patches that hopefully fix SLUB statistics for
merged case. Lets see what Christoph and David think of them and if
it's a dead end, I'd be inclined to rip out slab merging
completely....

                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
