Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 081786B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 15:00:40 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3958998pad.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 12:00:40 -0700 (PDT)
Date: Mon, 29 Oct 2012 12:00:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com> <20121015144412.GA2173@barrios> <CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com> <20121016061854.GB3934@barrios> <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
 <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com> <20121022235321.GK13817@bbox> <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 29 Oct 2012, Luigi Semenzato wrote:

> I managed to get the stack trace for the process that refuses to die.
> I am not sure it's due to the deadlock described in earlier messages.
> I will investigate further.
> 
> [96283.704390] chrome          x 815ecd20     0 16573   1112 0x00100104
> [96283.704405]  c107fe34 00200046 f57ae000 815ecd20 815ecd20 ec0b645a
> 0000578f f67cfd20
> [96283.704427]  d0a9a9a0 c107fdf8 81037be5 f5bdf1e8 f6021800 00000000
> c107fe04 00200202
> [96283.704449]  c107fe0c 00200202 f5bdf1b0 c107fe24 8117ddb1 00200202
> f5bdf1b0 f5bdf1b8
> [96283.704471] Call Trace:
> [96283.704484]  [<81037be5>] ? queue_work_on+0x2d/0x39
> [96283.704497]  [<8117ddb1>] ? put_io_context+0x52/0x6a
> [96283.704510]  [<813b68f6>] schedule+0x56/0x58
> [96283.704520]  [<81028525>] do_exit+0x63e/0x640

Could you find out where this happens to be in the function?  If you 
enable CONFIG_DEBUG_INFO, you should be able to use gdb on vmlinux and 
find out with l *do_exit+0x63e.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
