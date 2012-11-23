Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 72F856B005D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 03:08:45 -0500 (EST)
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz> <50AED854.7080300@gmail.com>
Message-ID: <1353658123.36385.YahooMailNeo@web141101.mail.bf1.yahoo.com>
Date: Fri, 23 Nov 2012 00:08:43 -0800 (PST)
From: metin d <metdos@yahoo.com>
Reply-To: metin d <metdos@yahoo.com>
Subject: Re: Problem in Page Cache Replacement
In-Reply-To: <50AED854.7080300@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

----- Original Message -----=0A=0AFrom: Jaegeuk Hanse <jaegeuk.hanse@gmail.=
com>=0ATo: metin d <metdos@yahoo.com>=0ACc: Jan Kara <jack@suse.cz>; "linux=
-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>; linux-mm@kvack.org=
=0ASent: Friday, November 23, 2012 3:58 AM=0ASubject: Re: Problem in Page C=
ache Replacement=0A=0AOn 11/21/2012 02:25 AM, Jan Kara wrote:=0A> On Tue 20=
-11-12 09:42:42, metin d wrote:=0A>> I have two PostgreSQL databases named =
data-1 and data-2 that sit on the=0A>> same machine. Both databases keep 40=
 GB of data, and the total memory=0A>> available on the machine is 68GB.=0A=
>>=0A>> I started data-1 and data-2, and ran several queries to go over all=
 their=0A>> data. Then, I shut down data-1 and kept issuing queries against=
 data-2.=0A>> For some reason, the OS still holds on to large parts of data=
-1's pages=0A>> in its page cache, and reserves about 35 GB of RAM to data-=
2's files. As=0A>> a result, my queries on data-2 keep hitting disk.=0A>>=
=0A>> I'm checking page cache usage with fincore. When I run a table scan q=
uery=0A>> against data-2, I see that data-2's pages get evicted and put bac=
k into=0A>> the cache in a round-robin manner. Nothing happens to data-1's =
pages,=0A>> although they haven't been touched for days.=0A=0A> Hi metin d,=
=0A=0A> fincore is a tool or ...? How could I get it?=0A=0A> Regards,=0A> J=
aegeuk=0A=0A=0AHi=A0Jaegeuk,=0A=0AYes, it is a tool, you get it from here :=
=0Ahttp://code.google.com/p/linux-ftools/=0A=0A=0ARegards,=0AMetin=0A>>=0A>=
> Does anybody know why data-1's pages aren't evicted from the page cache?=
=0A>> I'm open to all kind of suggestions you think it might relate to prob=
lem.=0A>=A0 =A0 Curious. Added linux-mm list to CC to catch more attention.=
 If you run=0A> echo 1 >/proc/sys/vm/drop_caches=0A>=A0 =A0 does it evict d=
ata-1 pages from memory?=0A>=0A>> This is an EC2 m2.4xlarge instance on Ama=
zon with 68 GB of RAM and no=0A>> swap space. The kernel version is:=0A>>=
=0A>> $ uname -r=0A>> 3.2.28-45.62.amzn1.x86_64=0A>> Edit:=0A>>=0A>> and it=
 seems that I use one NUMA instance, if=A0 you think that it can a problem.=
=0A>>=0A>> $ numactl --hardware=0A>> available: 1 nodes (0)=0A>> node 0 cpu=
s: 0 1 2 3 4 5 6 7=0A>> node 0 size: 70007 MB=0A>> node 0 free: 360 MB=0A>>=
 node distances:=0A>> node=A0  0=0A>>=A0 =A0 0:=A0 10=0A> =A0=A0=A0 =A0=A0=
=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
