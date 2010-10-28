Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 61BBA8D0004
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 02:09:41 -0400 (EDT)
Received: by iwn38 with SMTP id 38so927705iwn.14
        for <linux-mm@kvack.org>; Wed, 27 Oct 2010 23:09:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
	<AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
	<AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
Date: Thu, 28 Oct 2010 12:09:36 +0600
Message-ID: <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
Subject: 2.6.36 io bring the system to its knees
From: Aidar Kultayev <the.aidar@gmail.com>
Content-Type: multipart/mixed; boundary=20cf30434da6c598d00493a72fb2
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mingo@elte.hu
List-ID: <linux-mm.kvack.org>

--20cf30434da6c598d00493a72fb2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

QUOTE:***
And yes, we'd very much like to fix such slowdowns via heuristics as
well (detecting large sequential IO and not letting it poison the
existing cache), so good bugreports and reproducing testcases sent to
linux-kernel@vger.kernel.org and people willing to try out
experimental kernel patches would definitely be welcome.

Thanks,

Ingo

*** http://ask.slashdot.org/story/10/10/23/1828251/The-State-of-Linux-IO-Sc=
heduling-For-the-Desktop#commentlisting

I'll be rather quick & to the point here.

I get & run stable kernels the same day they appear on kernel.org in
hope to get away from these annoying, ignored, neglected slowdowns.

.config attached - I have Lenovo ThinkPad T400, Core2Duo T9400, 4Gb
DDR2, w/integrated GM45 - xf86-video-intel, iwlagn for the intel 5300
wifi, CFS, ext2 for
swap partition - 4Gb, ext3 for boot, ext4 - 400Gb for everything else.
All the hardware I have runs linux natively.
No kernel helped me from the days of 2.6.28.x upto 2.6.36. The dubbed
slowdown fixes never worked for me.
The kernel config choices are rather typical : NO_HZ, I don't go crazy for
1000Hz and use 100 or 250Hz and voluntary preemption.
Regarding the userland:
Love choices, hence nothing but Gentoo + KDE4. Multilib. Some relevant
info here:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
emerge --info
Portage 2.1.8.3 (default/linux/amd64/10.0/desktop, gcc-4.5.1,
glibc-2.11.2-r0, 2.6.36 x86_64)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
System uname: Linux-2.6.36-x86_64-Intel-R-_Core-TM-2_Duo_CPU_T9400_@_2.53GH=
z-with-gentoo-1.12.13
Timestamp of tree: Tue, 26 Oct 2010 10:30:01 +0000
app-shells/bash: =A0 =A0 4.1_p7
dev-java/java-config: 2.1.11
dev-lang/python: =A0 =A0 2.5.4-r4, 2.6.5-r3, 3.1.2-r4
dev-util/cmake: =A0 =A0 =A02.8.1-r2
sys-apps/baselayout: 1.12.13
sys-apps/sandbox: =A0 =A02.3-r1
sys-devel/autoconf: =A02.13, 2.65-r1
sys-devel/automake: =A01.7.9-r1, 1.8.5-r4, 1.9.6-r3, 1.10.3, 1.11.1
sys-devel/binutils: =A02.20.1-r1
sys-devel/gcc: =A0 =A0 =A0 4.5.1
sys-devel/gcc-config: 1.4.1
sys-devel/libtool: =A0 2.2.10
sys-devel/make: =A0 =A0 =A03.81-r2
CBUILD=3D"x86_64-pc-linux-gnu"
CFLAGS=3D"-O2 -pipe -march=3Dnative"
CHOST=3D"x86_64-pc-linux-gnu"
CONFIG_PROTECT=3D"/etc /usr/share/X11/xkb /usr/share/config /var/lib/hsqldb=
"
CONFIG_PROTECT_MASK=3D"/etc/ca-certificates.conf /etc/env.d
/etc/env.d/java/ /etc/fonts/fonts.conf /etc/gconf
/etc/php/apache2-php5/ext-active/ /etc/php/cgi-php5/ext-active/
/etc/php/cli-php5/ext-active/ /etc/revdep-rebuild /etc/sandbox.d
/etc/terminfo"
CXXFLAGS=3D"-O2 -pipe -march=3Dnative"
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Now, I know, Ingo said he wants : "good bugreports and reproducing
testcases" and my testcase is very real life and rather replicates my
typical use of computer these days:

- VirtualBox running XP only to look at some 2007 ppts ( the Ooo3
doens't cut it )
- JuK ( or VLC ) KDE's music player - some music in the background
- Chromium browser, with bunch of tabs with J2EE/J2SE javadocs, eats
out some significant swap space
- bash terminals
- ktorrent
- PDFs opened in okular, Adobe reader
- sync'ing portage tree & emerging new ebuilds ( usually with gentoo )
- Netbeans, Eclipse, apache, vsftd, sshd, tomcat and the whole 9 yards.

How do I notice slowdowns ? The JuK lags so badly that it can't play
any music, the mouse pointer freezes, kwin effects freeze for few
seconds.
How can I make it much worse ? I can try & run disk clean up under XP,
that is running in VBox, with folder compression. On top of it if I
start copying big files in linux ( 700MB avis, etc ), GUI effects
freeze, mouse pointer freezes for few seconds.

And this is on 2.6.36 that is supposed to cure these "features". From
this perspective, 2.6.36 is no better than any previous stable kernel
I've tried. Probably as bad with regards to IO issues.


Find attached screenshot ( latencytop_n_powertop.png ) which depicts
artifacts where the window manager froze at the time I was trying to
see a tab in Konsole where the powertop was running.

At the time, in the other tabs of the Konsole the following was running :
.dd if=3D/dev/zero of=3Dtest.10g bs=3D1M count=3D10000;rm test.10g
.cp /home/ak/1.distr/Linux/openSUSE-11.2-DVD-x86_64.iso
/home/lameruser/;rm /home/lameruser/openSUSE-11.2-DVD-x86_64.iso;
.dd if=3D/dev/zero of=3Dtest.10g bs=3D1M count=3D10000;rm test.10g
.cp /home/ak/funeral.avi /home/ak/0.junk/;rm /home/ak/0.junk/funeral.avi
.the XP under VBox was compacting its old files.

the iso is about 4Gb, the avi is about 700Mb

I do follow the problem here :
https://bugzilla.kernel.org/show_bug.cgi?id=3D12309

This is a monumental failure for kernel development project and=A0FLOSS
in general.
Poor management,=A0no leadership/championship,=A0no responsibility, neglect=
--20cf30434da6c598d00493a72fb2--
