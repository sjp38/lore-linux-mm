Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7BD528D0011
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 08:18:07 -0400 (EDT)
Received: by iwn38 with SMTP id 38so1291099iwn.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 05:18:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikx4zZwMLiAUrGKcH6yoo_PGgRA7nT9BzYMxQ89@mail.gmail.com>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
	<AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
	<AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
	<AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
	<AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
	<20101028090002.GA12446@elte.hu>
	<AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
	<AANLkTikyYQk1FH7d6jkw2GYHLN8jmghuGZQw=EFVgjuA@mail.gmail.com>
	<AANLkTikx4zZwMLiAUrGKcH6yoo_PGgRA7nT9BzYMxQ89@mail.gmail.com>
Date: Thu, 28 Oct 2010 18:18:05 +0600
Message-ID: <AANLkTi=Yt-vK-=8X8xu0htCQeEieEGfkWMCRYKUeK+PF@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Aidar Kultayev <the.aidar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@kernel.dk, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

http://picasaweb.google.com/aidar.eiei/LinuxIo#5533068249408411698

I will look into latencytop output and will figure out a usage pattern
that is most annoying with regards to IO.
Will try to see what leads to that & if possible to make a screenshot
of what is going on.
The thing is, I don't think the program that captures the screenshots
does it in a meaningful way, because at the moment the system is
brought to its knees, I don't think that this particular program
(KSnapshot) can get away from being affected. I mean it might take a
snapshot which is not representative enough.


thanks, Aidar

On Thu, Oct 28, 2010 at 5:48 PM, Pekka Enberg <penberg@kernel.org> wrote:
> On Thu, Oct 28, 2010 at 2:33 PM, Aidar Kultayev <the.aidar@gmail.com> wrote:
>> if it wasn't picasa, it would have been something else. I mean if I
>> kill picasa ( later on it was done indexing new pics anyway ), it
>> would have been for virtualbox to thrash the io. So, nope, getting rid
>> of picasa doesn't help either. In general the systems responsiveness
>> or sluggishness is dominated by those io operations going on - the DD
>> & CP & probably VBOX issuing whole bunch of its load for IO.
>
> Do you still see high latencies in vfs_lseek() and vfs_fsync()? I'm
> not a VFS expert but looking at your latencytop output, it seems that
> fsync grabs ->i_mutex which blocks vfs_llseek(), for example. I'm not
> sure why that causes high latencies though it's a mutex we're holding.
>
> On Thu, Oct 28, 2010 at 2:33 PM, Aidar Kultayev <the.aidar@gmail.com> wrote:
>> Another way I see these delays, is when I leave system overnight, with
>> ktorrent & juk(stopped) in the background. It takes some time for
>> WM(kwin) to work out ALT+TAB the very next morning. But this might be
>> because the WM(kwin & its code) has been swapped out, because of long
>> period of not using it.
>
> Yeah, that's probably paging overhead.
>
> P.S. Can you please upload latencytop output somewhere and post an URL
> to it so other people can also see it?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
