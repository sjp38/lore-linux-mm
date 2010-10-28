Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 906128D0011
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 07:48:22 -0400 (EDT)
Received: by gwb11 with SMTP id 11so1240618gwb.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 04:48:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikyYQk1FH7d6jkw2GYHLN8jmghuGZQw=EFVgjuA@mail.gmail.com>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
	<AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
	<AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
	<AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
	<AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
	<20101028090002.GA12446@elte.hu>
	<AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
	<AANLkTikyYQk1FH7d6jkw2GYHLN8jmghuGZQw=EFVgjuA@mail.gmail.com>
Date: Thu, 28 Oct 2010 14:48:20 +0300
Message-ID: <AANLkTikx4zZwMLiAUrGKcH6yoo_PGgRA7nT9BzYMxQ89@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Aidar Kultayev <the.aidar@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@kernel.dk, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2010 at 2:33 PM, Aidar Kultayev <the.aidar@gmail.com> wrote:
> if it wasn't picasa, it would have been something else. I mean if I
> kill picasa ( later on it was done indexing new pics anyway ), it
> would have been for virtualbox to thrash the io. So, nope, getting rid
> of picasa doesn't help either. In general the systems responsiveness
> or sluggishness is dominated by those io operations going on - the DD
> & CP & probably VBOX issuing whole bunch of its load for IO.

Do you still see high latencies in vfs_lseek() and vfs_fsync()? I'm
not a VFS expert but looking at your latencytop output, it seems that
fsync grabs ->i_mutex which blocks vfs_llseek(), for example. I'm not
sure why that causes high latencies though it's a mutex we're holding.

On Thu, Oct 28, 2010 at 2:33 PM, Aidar Kultayev <the.aidar@gmail.com> wrote:
> Another way I see these delays, is when I leave system overnight, with
> ktorrent & juk(stopped) in the background. It takes some time for
> WM(kwin) to work out ALT+TAB the very next morning. But this might be
> because the WM(kwin & its code) has been swapped out, because of long
> period of not using it.

Yeah, that's probably paging overhead.

P.S. Can you please upload latencytop output somewhere and post an URL
to it so other people can also see it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
