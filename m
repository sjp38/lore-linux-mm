Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7776A6B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 20:54:17 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so11334094qcx.4
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 17:54:17 -0800 (PST)
Received: from nm48.bullet.mail.bf1.yahoo.com (nm48.bullet.mail.bf1.yahoo.com. [216.109.114.64])
        by mx.google.com with SMTP id lc9si29056397qeb.62.2013.12.30.17.54.16
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 17:54:16 -0800 (PST)
References: <1388341026.52582.YahooMailNeo@web160105.mail.bf1.yahoo.com> <52C0854D.2090802@googlemail.com>
Message-ID: <1388454855.7071.YahooMailNeo@web160101.mail.bf1.yahoo.com>
Date: Mon, 30 Dec 2013 17:54:15 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: Help about calculating total memory consumption during booting
In-Reply-To: <52C0854D.2090802@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Beller <stefanbeller@googlemail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

=0A=0A=0A=0A=0A>________________________________=0A> From: Stefan Beller <s=
tefanbeller@googlemail.com>=0A>To: PINTU KUMAR <pintu_agarwal@yahoo.com>; "=
linux-mm@kvack.org" <linux-mm@kvack.org>; "linux-kernel@vger.kernel.org" <l=
inux-kernel@vger.kernel.org>; "mgorman@suse.de" <mgorman@suse.de> =0A>Sent:=
 Monday, 30 December 2013 1:55 AM=0A>Subject: Re: Help about calculating to=
tal memory consumption during booting=0A> =0A>=0A>On 29.12.2013 19:17, PINT=
U KUMAR wrote:=0A>> Hi,=0A>> =0A>> I need help in roughly calculating the t=
otal memory consumption in an embedded Linux system just after booting is f=
inished.=0A>> I know, I can see the memory stats using "free" and "/proc/me=
minfo"=0A>> =0A>> But, I need the breakup of "Used" memory during bootup, f=
or both kernel space and user application.=0A>> =0A>> Example, on my ARM ma=
chine with 128MB RAM, the free memory reported is roughly:=0A>> Total: 90MB=
=0A>> Used: 88MB=0A>> Free: 2MB=0A>> Buffer+Cached: (5+19)MB=0A>> =0A>> Now=
, my question is, how to find the breakup of this "Used" memory of "88MB".=
=0A>> This should include both kernel space allocation and user application=
 allocation(including daemons).=0A>> =0A>=0A>http://www.linuxatemyram.com/ =
dont panic ;)=0A>=0A>How about htop, top or=0A>"valgrind --tool massif"=0A>=
=0A>=0A=0A=0A=0AThanks for the reply, I know about top, but top does not he=
lp much in arriving at the total memory consumption.=0A=0A=0AI need the phy=
sical memory usage breakup of each process during bootup, with a segregate =
of user and kernel allocation.=0A=0A1) If I add up all "Pss" field in "proc=
/<PID>/smaps, do I get the total Used memory?=0A2) Is the Pss value include=
s the kernel side allocation as well?=0A3) What fields I should choose from=
 /proc/meminfo" to correctly arrive at the "Used" memory in the system?=0A4=
) What about the memory allocation for kernel threads during booting? Why d=
oes its Pss/Rss value shows 0 always=0A=0AI already tried adding up all "PS=
S" values in every PIDs, but still it does not match any where near to the =
total used memory in the system.=0A=0APlease help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
