Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 6FC9716E65
	for <linux-mm@kvack.org>; Thu, 22 Mar 2001 07:22:58 -0300 (EST)
Date: Thu, 22 Mar 2001 06:24:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <m18zly2pam.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.21.0103220622390.21415-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 22 Mar 2001, Eric W. Biederman wrote:

> Is there ever a case where killing init is the right thing to do? My
> impression is that if init is selected the whole machine dies. If you
> can kill init and still have a machine that mostly works, then I guess
> it makes some sense not to kill it.
>
> Guaranteeing not to select init can buy you piece of mind because
> init if properly setup can put the machine back together again, while
> not special casing init means something weird might happen and init
> would be selected.

When something weird happens, it might be better to kill
init and have the machine reset itself after the panic
(echo 30 > /proc/sys/kernel/panic).

Killing all other things and leaving just init intact
makes for a machine which is as good as dead, without a
chance for recovery-by-reboot...

OTOH, I haven't heard of the OOM killer ever chosing init,
not even of people who tried creating these special kinds
of situations to trigger it on purpose.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
