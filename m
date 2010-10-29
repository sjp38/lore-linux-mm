Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E05668D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 11:34:01 -0400 (EDT)
Received: by ywl5 with SMTP id 5so1612508ywl.14
        for <linux-mm@kvack.org>; Fri, 29 Oct 2010 08:33:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101029145212.GA21205@thunk.org>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
	<AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
	<AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
	<AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
	<AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
	<20101028090002.GA12446@elte.hu>
	<AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
	<20101028133036.GA30565@elte.hu>
	<20101028170132.GY27796@think>
	<AANLkTikgO=n88ZAQ6EYAg1+aC1d0+o923FYyhkOouaH5@mail.gmail.com>
	<20101029145212.GA21205@thunk.org>
Date: Fri, 29 Oct 2010 21:33:56 +0600
Message-ID: <AANLkTim-A7DLOOw4myQU3Lfip+ZEE32F2Ap_PJXuxG6G@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Aidar Kultayev <the.aidar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>, Pekka Enberg <penberg@kernel.org>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

puling the git now - I will try whatever you throw at me.

On Fri, Oct 29, 2010 at 8:52 PM, Ted Ts'o <tytso@mit.edu> wrote:
> On Thu, Oct 28, 2010 at 08:57:49PM +0300, Pekka Enberg wrote:
>> Don't we need to call ext4_should_writeback_data() before we drop the
>> lock? It pokes at ->i_mode which needs ->i_mutex AFAICT.
>
> No, it should be fine. =A0It's not like a file is going to change from
> being a regular file to a directory or vice versa. =A0:-)
>
> From a quick inspection it looks OK, but I haven't had the time to
> look more closely to be 100% sure, and of course I haven't run it
> through a battery of regression tests. =A0For normal usage it should be
> fine though.
>
> Aidar, if you'd be willing to try it with this patch applied, and with
> the file system mounted data=3Dwriteback, and then let me know what the
> latencytop reports, that would be useful. =A0I'm fairly sure that fixing
> llseek() probably won't make that much difference, since it will
> probably spread things out to other places, but it would be good to
> make the experiment.
>
> We will probably also need to use the uninitialized bit for protecting
> data from showing up after a crash for extent-based files, and turning
> on data=3Dwriteback is a good way to simulate that. =A0(Sorry, no way
> we're going to make a change like that this merge cycle, but that
> might be something we could do for 2.6.38.) =A0But I am curious to see
> what are the next things that come up as being problematic after that.
>
> Thanks,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0- Ted
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
