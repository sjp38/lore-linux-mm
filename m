Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 1A0E06B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 08:11:29 -0500 (EST)
Message-ID: <1328533887.46591.YahooMailNeo@web111709.mail.gq1.yahoo.com>
Date: Mon, 6 Feb 2012 05:11:27 -0800 (PST)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: commit memory is larger than physical and limit
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Dear all,=0AI noticed that committed memory is much higher than physical me=
mory and commit limit.=0A=0Aadmin@tiger:~$ cat /proc/meminfo=0AMemTotal:=A0=
=A0=A0=A0=A0=A0 66108396 kB=0AMemFree:=A0=A0=A0=A0=A0=A0=A0 50265064 kB=0AB=
uffers:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0ACached:=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 403164 kB=0ASwapCached:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 0 kB=0ACommitLimit:=A0=A0=A0 33054196 kB=0ACommitted_AS:=A0=A0 16045284=
8 kB=0A=0A=A0=0ACan someone explain is it good or bad? How it is possible?=
=0A=0A=0A// Naderan *Mahmood;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
