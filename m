Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 19DBA6B00B5
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 07:33:59 -0400 (EDT)
Received: by yxm34 with SMTP id 34so1237341yxm.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 04:33:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
	<AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
	<AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
	<AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
	<AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
	<20101028090002.GA12446@elte.hu>
	<AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
Date: Thu, 28 Oct 2010 17:33:57 +0600
Message-ID: <AANLkTikyYQk1FH7d6jkw2GYHLN8jmghuGZQw=EFVgjuA@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Aidar Kultayev <the.aidar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

if it wasn't picasa, it would have been something else. I mean if I
kill picasa ( later on it was done indexing new pics anyway ), it
would have been for virtualbox to thrash the io. So, nope, getting rid
of picasa doesn't help either. In general the systems responsiveness
or sluggishness is dominated by those io operations going on - the DD
& CP & probably VBOX issuing whole bunch of its load for IO.

Another way I see these delays, is when I leave system overnight, with
ktorrent & juk(stopped) in the background. It takes some time for
WM(kwin) to work out ALT+TAB the very next morning. But this might be
because the WM(kwin & its code) has been swapped out, because of long
period of not using it.

But, in general, I have troubles with responsiveness, when I try to
restore my virtualbox image from saved state. If there is a DD doing
its stuff while virtualbox is restoring its image, I see those nasty
delays - the kwin, mouse pointer, etc...

thanks Aidar

PS : the good thing is, and I am getting used to it, I don't loose
data, I mean the system doesn't hang, just freezes for a while :)

On Thu, Oct 28, 2010 at 5:16 PM, Pekka Enberg <penberg@kernel.org> wrote:
> * Pekka Enberg <penberg@kernel.org> wrote:
>>> On Thu, Oct 28, 2010 at 9:09 AM, Aidar Kultayev <the.aidar@gmail.com> w=
rote:
>>> > Find attached screenshot ( latencytop_n_powertop.png ) which depicts
>>> > artifacts where the window manager froze at the time I was trying to
>>> > see a tab in Konsole where the powertop was running.
>>>
>>> You seem to have forgotten to include the attachment.
>
> On Thu, Oct 28, 2010 at 12:00 PM, Ingo Molnar <mingo@elte.hu> wrote:
>> I got it - it appears it was too large for lkml's ~500K mail size limit.
>>
>> Aidar, mind sending a smaller image?
>
> Looks mostly VFS to me. Aidar, does killing Picasa make things
> smoother for you? If so, maybe the VFS scalability patches will help.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Pekka
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
