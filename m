Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A811E6B00EE
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 04:15:01 -0400 (EDT)
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <1db776d865939be598cdb80054cf5d93.squirrel@xenotime.net> <1312874259.89770.YahooMailNeo@web111704.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108090900170.30199@chino.kir.corp.google.com>
Message-ID: <1312964098.7449.YahooMailNeo@web111712.mail.gq1.yahoo.com>
Date: Wed, 10 Aug 2011 01:14:58 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: running of out memory => kernel crash
In-Reply-To: <alpine.DEB.2.00.1108090900170.30199@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, "\"linux-kernel@vger.kernel.org\"" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>If you're using cpusets or mempolicies, you must ensure that all tasks =0A=
>attached to either of them are not set to OOM_DISABLE.=A0 It seems unlikel=
y =0A>that you're using those, so it seems like a system-wide oom condition=
.=0A=A0=0AI didn't do that manually. What is the default behaviour? Does oo=
m=0Aworking or not?=0A=0A>If you're using cpusets or mempolicies, you must =
ensure that all tasks =0A>attached to either of them are not set to OOM_DIS=
ABLE.=A0 It seems unlikely =0A>that you're using those, so it seems like a =
system-wide oom condition.=0A=0AFor a user process:=0A=0Aroot@srv:~# cat /p=
roc/18564/oom_score=0A9198=0Aroot@srv:~# cat /proc/18564/oom_adj=0A0=0A=0AA=
nd for "init" process:=0A=0Aroot@srv:~# cat /proc/1/oom_score=0A17509=0Aroo=
t@srv:~# cat /proc/1/oom_adj=0A0=0A=0ABased on my understandings, in an out=
 of memory condition (oom),=0Athe init process is more eligible to be kille=
d!!!!!!! Is that right?=0A=0AAgain I didn't get my answer yet:=0AWhat is th=
e default behavior of linux in an oom condition? If the default is,=0Acrash=
 (kernel panic), then how can I change that in such a way to kill=0Athe hun=
gry process?=0A=0AThanks a lot.=0A=0A// Naderan *Mahmood;=0A=0A=0A----- Ori=
ginal Message -----=0AFrom: David Rientjes <rientjes@google.com>=0ATo: Mahm=
ood Naderan <nt_mahmood@yahoo.com>=0ACc: Randy Dunlap <rdunlap@xenotime.net=
>; "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>; linux-mm@=
kvack.org=0ASent: Tuesday, August 9, 2011 8:33 PM=0ASubject: Re: running of=
 out memory =3D> kernel crash=0A=0AOn Tue, 9 Aug 2011, Mahmood Naderan wrot=
e:=0A=0A> >Do you have any kernel log panic/oops/Bug messages?=0A> =A0=0A> =
Actually, that happened for one my diskless nodes 10 days ago.=0A> What I s=
aw on the screen (not the logs), was =0A> "running out of memory.... kernel=
 panic....."=0A> =0A=0AThe only similar message in the kernel is "Out of me=
mory and no killable =0Aprocesses..." and that panics the machine when ther=
e are no eligible =0Atasks to kill.=0A=0AIf you're using cpusets or mempoli=
cies, you must ensure that all tasks =0Aattached to either of them are not =
set to OOM_DISABLE.=A0 It seems unlikely =0Athat you're using those, so it =
seems like a system-wide oom condition.=A0 Do =0Acat /proc/*/oom_score and =
make sure at least some threads have a non-zero =0Abadness score.=A0 Otherw=
ise, you'll need to adjust their =0A/proc/pid/oom_score_adj settings to not=
 be -1000.=0A=0ARandy also added linux-mm@kvack.org to the cc, but you remo=
ved it; please =0Adon't do that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
