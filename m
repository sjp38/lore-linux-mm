Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AA29290014F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 03:07:04 -0400 (EDT)
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <1db776d865939be598cdb80054cf5d93.squirrel@xenotime.net> <1312874259.89770.YahooMailNeo@web111704.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108090900170.30199@chino.kir.corp.google.com> <1312964098.7449.YahooMailNeo@web111712.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108102106410.14230@chino.kir.corp.google.com>
Message-ID: <1313046422.18195.YahooMailNeo@web111711.mail.gq1.yahoo.com>
Date: Thu, 11 Aug 2011 00:07:02 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: running of out memory => kernel crash
In-Reply-To: <alpine.DEB.2.00.1108102106410.14230@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, "\"\"linux-kernel@vger.kernel.org\"\"" <linux-kernel@vger.kernel.org>, "\"linux-mm@kvack.org\"" <linux-mm@kvack.org>

>The default behavior is to kill all eligible and unkillable threads until =
=0A>there are none left to sacrifice (i.e. all kthreads and OOM_DISABLE).=
=0A=A0=0AIn a simple test with virtualbox, I reduced the amount of ram to 3=
00MB. =0AThen I ran "swapoff -a" and opened some applications. I noticed th=
at the free=0Aspaces is kept around 2-3MB and "kswapd" is running. Also I s=
aw that disk=0Aactivity was very high. =0AThat mean although "swap" partiti=
on is turned off, "kswapd" was trying to do=0Asomething. I wonder how that =
behavior can be explained?=0A=0A>Ok, so you don't have a /proc/pid/oom_scor=
e_adj, so you're using a kernel =0A>that predates 2.6.36.=0AYes, the srv ma=
chine that I posted those results, has kernel before 2.6.36=0A=0A=0A=0A// N=
aderan *Mahmood;=0A=0A=0A----- Original Message -----=0AFrom: David Rientje=
s <rientjes@google.com>=0ATo: Mahmood Naderan <nt_mahmood@yahoo.com>=0ACc: =
Randy Dunlap <rdunlap@xenotime.net>; ""linux-kernel@vger.kernel.org"" <linu=
x-kernel@vger.kernel.org>; "linux-mm@kvack.org" <linux-mm@kvack.org>=0ASent=
: Thursday, August 11, 2011 8:39 AM=0ASubject: Re: running of out memory =
=3D> kernel crash=0A=0AOn Wed, 10 Aug 2011, Mahmood Naderan wrote:=0A=0A> >=
If you're using cpusets or mempolicies, you must ensure that all tasks =0A>=
 >attached to either of them are not set to OOM_DISABLE.=A0 It seems unlike=
ly =0A> >that you're using those, so it seems like a system-wide oom condit=
ion.=0A> =A0=0A> I didn't do that manually. What is the default behaviour? =
Does oom=0A> working or not?=0A> =0A=0AThe default behavior is to kill all =
eligible and unkillable threads until =0Athere are none left to sacrifice (=
i.e. all kthreads and OOM_DISABLE).=0A=0A> For a user process:=0A> =0A> roo=
t@srv:~# cat /proc/18564/oom_score=0A> 9198=0A> root@srv:~# cat /proc/18564=
/oom_adj=0A> 0=0A> =0A=0AOk, so you don't have a /proc/pid/oom_score_adj, s=
o you're using a kernel =0Athat predates 2.6.36.=0A=0A> And for "init" proc=
ess:=0A> =0A> root@srv:~# cat /proc/1/oom_score=0A> 17509=0A> root@srv:~# c=
at /proc/1/oom_adj=0A> 0=0A> =0A> Based on my understandings, in an out of =
memory condition (oom),=0A> the init process is more eligible to be killed!=
!!!!!! Is that right?=0A> =0A=0Ainit is exempt from oom killing, it's oom_s=
core is meaningless.=0A=0A> Again I didn't get my answer yet:=0A> What is t=
he default behavior of linux in an oom condition? If the default is,=0A> cr=
ash (kernel panic), then how can I change that in such a way to kill=0A> th=
e hungry process?=0A> =0A=0AYou either have /proc/sys/vm/panic_on_oom set o=
r it's killing a thread =0Athat is taking down the entire machine.=A0 If it=
's the latter, then please =0Acapture the kernel log and post it as Randy s=
uggested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
