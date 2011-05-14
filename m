Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 349506B0023
	for <linux-mm@kvack.org>; Sat, 14 May 2011 11:46:23 -0400 (EDT)
Received: by pxi9 with SMTP id 9so2817158pxi.14
        for <linux-mm@kvack.org>; Sat, 14 May 2011 08:46:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
References: <BANLkTi=XqROAp2MOgwQXEQjdkLMenh_OTQ@mail.gmail.com>
 <m2fwokj0oz.fsf@firstfloor.org> <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
 <20110512054631.GI6008@one.firstfloor.org> <BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
From: Andrew Lutomirski <luto@mit.edu>
Date: Sat, 14 May 2011 11:46:00 -0400
Message-ID: <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

[cc linux-mm]

On Thu, May 12, 2011 at 7:54 AM, Andrew Lutomirski <luto@mit.edu> wrote:
> On Thu, May 12, 2011 at 1:46 AM, Andi Kleen <andi@firstfloor.org> wrote:
>>> Here's a nice picture of alt-sysrq-m with lots of memory free but the
>>> system mostly hung. =A0I can still switch VTs.
>>
>> Would rather need backtraces. Try setting up netconsole or crashdump
>> first.
>
> Here are some logs for two different failure mores.
>
> incorrect_oom_kill.txt is an OOM kill when there was lots of available
> swap to use. =A0AFAICT the kernel should not have OOM killed at all.
>
> stuck_xyz is when the system is wedged with plenty (~300MB) free
> memory but no swap. =A0The sysrq files are self-explanatory.
> stuck-sysrq-f.txt is after the others so that it won't have corrupted
> the output. =A0After taking all that data, I waited awhile and started
> getting soft lockup messges.
>
> I'm having trouble reproducing the "stuck" failure mode on my
> lockdep-enabled kernel right now (the OOM kill is easy), so no lock
> state trace. =A0But I got one yesterday and IIRC it showed a few tty
> locks and either kworker or kcryptd holding (kqueue) and
> ((&io->work)).
>
> I compressed the larger files.
>
> --Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
