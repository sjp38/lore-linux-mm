Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 244956B0072
	for <linux-mm@kvack.org>; Tue,  1 Jan 2013 21:08:53 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id h16so12720619oag.33
        for <linux-mm@kvack.org>; Tue, 01 Jan 2013 18:08:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50E30736.9050207@gmx.de>
References: <50E2C87A.3090000@gmx.de>
	<50E30736.9050207@gmx.de>
Date: Wed, 2 Jan 2013 10:08:52 +0800
Message-ID: <CAJd=RBCq8zb06aehCZWoX2wO0=1F7GbnkRRjC+WVAc59Y6j8Qg@mail.gmail.com>
Subject: Re: kernel bug at mm/huge_memory.c:1789 for v3.8-rc1-91-g4a490b7
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, Jan 1, 2013 at 11:56 PM, Toralf F=C3=B6rster <toralf.foerster@gmx.d=
e> wrote:
> I found this in the syslog (sry for the big unnecessary JPEG in the previ=
ous message,
> I wasn't aware, that the syslogd was still working):
>
> 2013-01-01T12:15:28.000+01:00 n22 ntpd[3095]: Listen normally on 5 ppp0 8=
0.171.221.184 UDP 123
> 2013-01-01T12:15:28.000+01:00 n22 ntpd[3095]: peers refreshed
> 2013-01-01T12:18:32.394+01:00 n22 kernel: mapcount 0 page_mapcount 1
> 2013-01-01T12:18:32.394+01:00 n22 kernel: ------------[ cut here ]-------=
-----
> 2013-01-01T12:18:32.394+01:00 n22 kernel: kernel BUG at mm/huge_memory.c:=
1798!
>
Hey Toralf

Thanks for reporting the oops.
Other reported cases are  piled up at https://lkml.org/lkml/2012/12/24/173

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
