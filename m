Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 90CF86B0166
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 21:22:30 -0400 (EDT)
Date: Sun, 31 Oct 2010 09:22:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101031012224.GA8007@localhost>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
 <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
 <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
 <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Aidar Kultayev <the.aidar@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Ted Ts'o <tytso@mit.edu>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Hi Aidar,

On Thu, Oct 28, 2010 at 12:09:36PM +0600, Aidar Kultayev wrote:
> QUOTE:***
> And yes, we'd very much like to fix such slowdowns via heuristics as
> well (detecting large sequential IO and not letting it poison the
> existing cache), so good bugreports and reproducing testcases sent to
> linux-kernel@vger.kernel.org and people willing to try out
> experimental kernel patches would definitely be welcome.
> 
> Thanks,
> 
> Ingo
> 
> *** http://ask.slashdot.org/story/10/10/23/1828251/The-State-of-Linux-IO-Scheduling-For-the-Desktop#commentlisting
> 
> I'll be rather quick & to the point here.
> 
> I get & run stable kernels the same day they appear on kernel.org in
> hope to get away from these annoying, ignored, neglected slowdowns.
> 
> .config attached - I have Lenovo ThinkPad T400, Core2Duo T9400, 4Gb
> DDR2, w/integrated GM45 - xf86-video-intel, iwlagn for the intel 5300
> wifi, CFS, ext2 for
> swap partition - 4Gb, ext3 for boot, ext4 - 400Gb for everything else.

If possible I'd suggest to turn off the swap and check if it helps.
Some people reports(*) desktop responsiveness problems that can be
poor-man-fixed by disabling swap.

(*) https://bugzilla.kernel.org/show_bug.cgi?id=12309

> All the hardware I have runs linux natively.
> No kernel helped me from the days of 2.6.28.x upto 2.6.36. The dubbed
> slowdown fixes never worked for me.

There are multiple causes of slowdown. 2.6.36 includes some easy fix.
The swap problem is (maybe partly) root caused(**), however will need a
rather complex and intrusive patch to fix.

(**) http://www.spinics.net/lists/linux-fsdevel/msg35397.html

Thanks,
Fengguang

> The kernel config choices are rather typical : NO_HZ, I don't go crazy for
> 1000Hz and use 100 or 250Hz and voluntary preemption.
> Regarding the userland:
> Love choices, hence nothing but Gentoo + KDE4. Multilib. Some relevant
> info here:
> 
> ==============================================================================================
> emerge --info
> Portage 2.1.8.3 (default/linux/amd64/10.0/desktop, gcc-4.5.1,
> glibc-2.11.2-r0, 2.6.36 x86_64)
> =================================================================
> System uname: Linux-2.6.36-x86_64-Intel-R-_Core-TM-2_Duo_CPU_T9400_@_2.53GHz-with-gentoo-1.12.13
> Timestamp of tree: Tue, 26 Oct 2010 10:30:01 +0000
> app-shells/bash: A  A  4.1_p7
> dev-java/java-config: 2.1.11
> dev-lang/python: A  A  2.5.4-r4, 2.6.5-r3, 3.1.2-r4
> dev-util/cmake: A  A  A 2.8.1-r2
> sys-apps/baselayout: 1.12.13
> sys-apps/sandbox: A  A 2.3-r1
> sys-devel/autoconf: A 2.13, 2.65-r1
> sys-devel/automake: A 1.7.9-r1, 1.8.5-r4, 1.9.6-r3, 1.10.3, 1.11.1
> sys-devel/binutils: A 2.20.1-r1
> sys-devel/gcc: A  A  A  4.5.1
> sys-devel/gcc-config: 1.4.1
> sys-devel/libtool: A  2.2.10
> sys-devel/make: A  A  A 3.81-r2
> CBUILD="x86_64-pc-linux-gnu"
> CFLAGS="-O2 -pipe -march=native"
> CHOST="x86_64-pc-linux-gnu"
> CONFIG_PROTECT="/etc /usr/share/X11/xkb /usr/share/config /var/lib/hsqldb"
> CONFIG_PROTECT_MASK="/etc/ca-certificates.conf /etc/env.d
> /etc/env.d/java/ /etc/fonts/fonts.conf /etc/gconf
> /etc/php/apache2-php5/ext-active/ /etc/php/cgi-php5/ext-active/
> /etc/php/cli-php5/ext-active/ /etc/revdep-rebuild /etc/sandbox.d
> /etc/terminfo"
> CXXFLAGS="-O2 -pipe -march=native"
> ==============================================================================================
> 
> Now, I know, Ingo said he wants : "good bugreports and reproducing
> testcases" and my testcase is very real life and rather replicates my
> typical use of computer these days:
> 
> - VirtualBox running XP only to look at some 2007 ppts ( the Ooo3
> doens't cut it )
> - JuK ( or VLC ) KDE's music player - some music in the background
> - Chromium browser, with bunch of tabs with J2EE/J2SE javadocs, eats
> out some significant swap space
> - bash terminals
> - ktorrent
> - PDFs opened in okular, Adobe reader
> - sync'ing portage tree & emerging new ebuilds ( usually with gentoo )
> - Netbeans, Eclipse, apache, vsftd, sshd, tomcat and the whole 9 yards.
> 
> How do I notice slowdowns ? The JuK lags so badly that it can't play
> any music, the mouse pointer freezes, kwin effects freeze for few
> seconds.
> How can I make it much worse ? I can try & run disk clean up under XP,
> that is running in VBox, with folder compression. On top of it if I
> start copying big files in linux ( 700MB avis, etc ), GUI effects
> freeze, mouse pointer freezes for few seconds.
> 
> And this is on 2.6.36 that is supposed to cure these "features". From
> this perspective, 2.6.36 is no better than any previous stable kernel
> I've tried. Probably as bad with regards to IO issues.
> 
> 
> Find attached screenshot ( latencytop_n_powertop.png ) which depicts
> artifacts where the window manager froze at the time I was trying to
> see a tab in Konsole where the powertop was running.
> 
> At the time, in the other tabs of the Konsole the following was running :
> .dd if=/dev/zero of=test.10g bs=1M count=10000;rm test.10g
> .cp /home/ak/1.distr/Linux/openSUSE-11.2-DVD-x86_64.iso
> /home/lameruser/;rm /home/lameruser/openSUSE-11.2-DVD-x86_64.iso;
> .dd if=/dev/zero of=test.10g bs=1M count=10000;rm test.10g
> .cp /home/ak/funeral.avi /home/ak/0.junk/;rm /home/ak/0.junk/funeral.avi
> .the XP under VBox was compacting its old files.
> 
> the iso is about 4Gb, the avi is about 700Mb
> 
> I do follow the problem here :
> https://bugzilla.kernel.org/show_bug.cgi?id=12309
> 
> This is a monumental failure for kernel development project andA FLOSS
> in general.
> Poor management,A no leadership/championship,A no responsibility, neglect

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
