Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id BD1596B0031
	for <linux-mm@kvack.org>; Sun, 29 Dec 2013 13:19:51 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id e14so11441376iej.28
        for <linux-mm@kvack.org>; Sun, 29 Dec 2013 10:19:51 -0800 (PST)
Received: from nm31.bullet.mail.ne1.yahoo.com (nm31.bullet.mail.ne1.yahoo.com. [98.138.229.24])
        by mx.google.com with SMTP id jw1si52157649icc.114.2013.12.29.10.19.50
        for <linux-mm@kvack.org>;
        Sun, 29 Dec 2013 10:19:50 -0800 (PST)
Message-ID: <1388341026.52582.YahooMailNeo@web160105.mail.bf1.yahoo.com>
Date: Sun, 29 Dec 2013 10:17:06 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Help about calculating total memory consumption during booting
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

Hi,=0A=0AI need help in roughly calculating the total memory consumption in=
 an embedded Linux system just after booting is finished.=0AI know, I can s=
ee the memory stats using "free" and "/proc/meminfo"=0A=0ABut, I need the b=
reakup of "Used" memory during bootup, for both kernel space and user appli=
cation.=0A=0AExample, on my ARM machine with 128MB RAM, the free memory rep=
orted is roughly:=0ATotal: 90MB=0AUsed: 88MB=0AFree: 2MB=0ABuffer+Cached: (=
5+19)MB=0A=0ANow, my question is, how to find the breakup of this "Used" me=
mory of "88MB".=0AThis should include both kernel space allocation and user=
 application allocation(including daemons).=0A=0AIf anybody knows about any=
 tools(or techniques) please help.=0A=0AFew doubts:=0A1) If I add up all "P=
ss" field in "proc/<PID>/smaps, do I get the total Used memory?=0A2) Is the=
 Pss value includes the kernel side allocation as well?=0A3) What fields I =
should choose from ?proc/meminfo" to correctly arrive at the "Used" memory =
in the system?=0A4) What about the memory allocation for kernel threads dur=
ing booting? Why does its Pss/Rss value shows 0 always?=0A=0APlease help.=
=0A=0A=0AThank You!=0ARegards,=0APintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
