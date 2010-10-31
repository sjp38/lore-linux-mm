Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8BB546B0173
	for <linux-mm@kvack.org>; Sun, 31 Oct 2010 13:49:41 -0400 (EDT)
Received: by gyh20 with SMTP id 20so3148563gyh.14
        for <linux-mm@kvack.org>; Sun, 31 Oct 2010 10:49:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101031023145.GB1869@thunk.org>
References: <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
	<20101028090002.GA12446@elte.hu>
	<AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
	<20101028133036.GA30565@elte.hu>
	<20101028170132.GY27796@think>
	<AANLkTikgO=n88ZAQ6EYAg1+aC1d0+o923FYyhkOouaH5@mail.gmail.com>
	<20101029145212.GA21205@thunk.org>
	<AANLkTim-A7DLOOw4myQU3Lfip+ZEE32F2Ap_PJXuxG6G@mail.gmail.com>
	<20101030091440.GA15276@elte.hu>
	<AANLkTim-hgA3-9T_N5k53Sga5LMazMQPmmQZzQsoQvRY@mail.gmail.com>
	<20101031023145.GB1869@thunk.org>
Date: Sun, 31 Oct 2010 18:49:39 +0100
Message-ID: <AANLkTimc4wphG4BXv=rN8MVvFDhnkjtWn_hgHzyJVucw@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Corrado Zoccolo <czoccolo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>, Aidar Kultayev <the.aidar@gmail.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Sun, Oct 31, 2010 at 3:31 AM, Ted Ts'o <tytso@mit.edu> wrote:
> On Sat, Oct 30, 2010 at 07:02:35PM +0600, Aidar Kultayev wrote:
>> the system is/was doing :
>> .dd if=3D/dev/zero of=3Dtest.10g bs=3D1M count=3D10000;rm test.10g
>> .netbeans
>> .compiling gcc-4.5.1
>> .running VBox, which wasn't doing any IO. The guest os was idle in other=
 words
>> .vlc
>> .chromium
>> .firefox
>> and bunch of other small stuff.
>>
>> Even without having running DD, the mouse cursor would occasionally
>> lag. The alt+tab effect in KWin would take 5+seconds to workout.
>> When I run DD on top of the workload it consistently made system much
>> more laggy. The cursor would freeze much more frequent. It is like if
>> you drag your mouse physically, but the cursor on the screen would
>> jump discretely, in other words there is no continuity.
>> Music would stop.
>
> If you start shutting down tasks, Vbox, netbeans, chromium, etc., at
> what point does the cursor start tracking the system easily? =C2=A0Is the
> system swapping? =C2=A0Do you know how to use tools like dstat or iostat =
to
> see if the system is actively writing to the swap partition? =C2=A0(And a=
re
> you using a swap partition or a swap file?)
>
> The fact that cursor isn't tracking well even when the dd is running,
> and presumably the only source of I/O is the gcc and vlc, makes me
> suspect that you may be swapping pretty heavily. =C2=A0Have you tried
> investigating that possibility, and made sure it has been ruled out?

Something to try is also to raise X cpu scheduling priority, since I
would be really surprised if we evict from memory the routine that
draws the cursor.
BTW, I've seen the cursor jumping problem even when not swapping, and
with minimal *real* disk activity (but with heavy usage of a fuse
filesystem providing remote resources), and high cpu activity.
Raising X priority solved the problem with the mouse pointer, but the
gui programs still didn't respond quickly...

Thanks
Corrado

>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0- Ted
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
