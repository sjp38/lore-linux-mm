Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 90CEC6B0071
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 03:25:17 -0500 (EST)
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz> <50AED854.7080300@gmail.com> <1353658123.36385.YahooMailNeo@web141101.mail.bf1.yahoo.com> <50AF3134.3090803@gmail.com>
Message-ID: <1353659115.24777.YahooMailNeo@web141102.mail.bf1.yahoo.com>
Date: Fri, 23 Nov 2012 00:25:15 -0800 (PST)
From: metin d <metdos@yahoo.com>
Reply-To: metin d <metdos@yahoo.com>
Subject: Re: Problem in Page Cache Replacement
In-Reply-To: <50AF3134.3090803@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

----- Original Message -----=0A=0AFrom: Jaegeuk Hanse <jaegeuk.hanse@gmail.=
com>=0ATo: metin d <metdos@yahoo.com>=0ACc: Jan Kara <jack@suse.cz>; "linux=
-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>; "linux-mm@kvack.or=
g" <linux-mm@kvack.org>=0ASent: Friday, November 23, 2012 10:17 AM=0ASubjec=
t: Re: Problem in Page Cache Replacement=0A=0AOn 11/23/2012 04:08 PM, metin=
 d wrote:=0A> ----- Original Message -----=0A>=0A> From: Jaegeuk Hanse <jae=
geuk.hanse@gmail.com>=0A> To: metin d <metdos@yahoo.com>=0A> Cc: Jan Kara <=
jack@suse.cz>; "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org=
>; linux-mm@kvack.org=0A> Sent: Friday, November 23, 2012 3:58 AM=0A> Subje=
ct: Re: Problem in Page Cache Replacement=0A>=0A> On 11/21/2012 02:25 AM, J=
an Kara wrote:=0A>> On Tue 20-11-12 09:42:42, metin d wrote:=0A>>> I have t=
wo PostgreSQL databases named data-1 and data-2 that sit on the=0A>>> same =
machine. Both databases keep 40 GB of data, and the total memory=0A>>> avai=
lable on the machine is 68GB.=0A>>>=0A>>> I started data-1 and data-2, and =
ran several queries to go over all their=0A>>> data. Then, I shut down data=
-1 and kept issuing queries against data-2.=0A>>> For some reason, the OS s=
till holds on to large parts of data-1's pages=0A>>> in its page cache, and=
 reserves about 35 GB of RAM to data-2's files. As=0A>>> a result, my queri=
es on data-2 keep hitting disk.=0A>>>=0A>>> I'm checking page cache usage w=
ith fincore. When I run a table scan query=0A>>> against data-2, I see that=
 data-2's pages get evicted and put back into=0A>>> the cache in a round-ro=
bin manner. Nothing happens to data-1's pages,=0A>>> although they haven't =
been touched for days.=0A>> Hi metin d,=0A>> fincore is a tool or ...? How =
could I get it?=0A>> Regards,=0A>> Jaegeuk=0A>=0A> Hi Jaegeuk,=0A>=0A> Yes,=
 it is a tool, you get it from here :=0A> http://code.google.com/p/linux-ft=
ools/=0A=0A=0A> Hi Metin,=0A=0A> Could you give me a link to download it? I=
 can't get it from the link =0A> you give me. Thanks in advance. :-)=0A=0A>=
 Regards,=0A> Jaegeuk=0A=0AHi=A0Jaegeuk,=0A=0AYou may need to install mercu=
rial on your system, I'm able to download source code with this command:=0A=
=0Ahg clone https://code.google.com/p/linux-ftools/=0A=0A=0ARegards,=0AMeti=
n=0A=0A>=0A>=0A> Regards,=0A> Metin=0A>>> Does anybody know why data-1's pa=
ges aren't evicted from the page cache?=0A>>> I'm open to all kind of sugge=
stions you think it might relate to problem.=0A>>=A0 =A0 =A0 Curious. Added=
 linux-mm list to CC to catch more attention. If you run=0A>> echo 1 >/proc=
/sys/vm/drop_caches=0A>>=A0 =A0 =A0 does it evict data-1 pages from memory?=
=0A>>=0A>>> This is an EC2 m2.4xlarge instance on Amazon with 68 GB of RAM =
and no=0A>>> swap space. The kernel version is:=0A>>>=0A>>> $ uname -r=0A>>=
> 3.2.28-45.62.amzn1.x86_64=0A>>> Edit:=0A>>>=0A>>> and it seems that I use=
 one NUMA instance, if=A0 you think that it can a problem.=0A>>>=0A>>> $ nu=
mactl --hardware=0A>>> available: 1 nodes (0)=0A>>> node 0 cpus: 0 1 2 3 4 =
5 6 7=0A>>> node 0 size: 70007 MB=0A>>> node 0 free: 360 MB=0A>>> node dist=
ances:=0A>>> node=A0  0=0A>>>=A0 =A0 =A0 0:=A0 10=0A>>=A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
