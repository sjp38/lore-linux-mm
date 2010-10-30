Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DF0446B015D
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 09:08:52 -0400 (EDT)
Received: by iwn38 with SMTP id 38so4024997iwn.14
        for <linux-mm@kvack.org>; Sat, 30 Oct 2010 06:08:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101030091440.GA15276@elte.hu>
References: <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
	<AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
	<AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
	<20101028090002.GA12446@elte.hu>
	<AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
	<20101028133036.GA30565@elte.hu>
	<20101028170132.GY27796@think>
	<AANLkTikgO=n88ZAQ6EYAg1+aC1d0+o923FYyhkOouaH5@mail.gmail.com>
	<20101029145212.GA21205@thunk.org>
	<AANLkTim-A7DLOOw4myQU3Lfip+ZEE32F2Ap_PJXuxG6G@mail.gmail.com>
	<20101030091440.GA15276@elte.hu>
Date: Sat, 30 Oct 2010 19:02:35 +0600
Message-ID: <AANLkTim-hgA3-9T_N5k53Sga5LMazMQPmmQZzQsoQvRY@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Aidar Kultayev <the.aidar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Ted Ts'o <tytso@mit.edu>, Pekka Enberg <penberg@kernel.org>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Hi,

here is what I have :

.ext4 mounted with data=3Dordered
.-tip tree ( uname -a gives : Linux pussy 2.6.36-tip+ )

here is the latencytop & powertop & top screenshot:

http://picasaweb.google.com/lh/photo/bMTgbVDoojwUeXtVdyvIKw?feat=3Ddirectli=
nk

the system is/was doing :
.dd if=3D/dev/zero of=3Dtest.10g bs=3D1M count=3D10000;rm test.10g
.netbeans
.compiling gcc-4.5.1
.running VBox, which wasn't doing any IO. The guest os was idle in other wo=
rds
.vlc
.chromium
.firefox
and bunch of other small stuff.

Even without having running DD, the mouse cursor would occasionally
lag. The alt+tab effect in KWin would take 5+seconds to workout.
When I run DD on top of the workload it consistently made system much
more laggy. The cursor would freeze much more frequent. It is like if
you drag your mouse physically, but the cursor on the screen would
jump discretely, in other words there is no continuity.
Music would stop.

I am free to try out anything here.

thanks, Aidar

On Sat, Oct 30, 2010 at 3:14 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Aidar Kultayev <the.aidar@gmail.com> wrote:
>
>> puling the git now - I will try whatever you throw at me.
>
> Ted, i stuck that patch into tip:out-of-tree as:
>
> =A022fd555f6c5f: <not for upstream> ext4: Relax i_mutex hold times
>
> So that Aidar can test things more easily via:
>
> =A0http://people.redhat.com/mingo/tip.git/README
>
> Thanks,
>
> =A0 =A0 =A0 =A0Ingo
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
