Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 123586B016B
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 04:50:42 -0400 (EDT)
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <CAK1hOcN7q=F=UV=aCAsVOYO=Ex34X0tbwLHv9BkYkA=ik7G13w@mail.gmail.com> <1313075625.50520.YahooMailNeo@web111715.mail.gq1.yahoo.com> <201108111938.25836.vda.linux@googlemail.com>
Message-ID: <1313571040.71372.YahooMailNeo@web111710.mail.gq1.yahoo.com>
Date: Wed, 17 Aug 2011 01:50:40 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: running of out memory => kernel crash
In-Reply-To: <201108111938.25836.vda.linux@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Cc: David Rientjes <rientjes@google.com>, Randy Dunlap <rdunlap@xenotime.net>, "\"\"linux-kernel@vger.kernel.org\"\"" <linux-kernel@vger.kernel.org>, "\"\"linux-mm@kvack.org\"\"" <linux-mm@kvack.org>

Thanks a lot Denys for your indepth response=0A=0A=A0=0A// Naderan *Mahmood=
;=0A=0A=0A----- Original Message -----=0AFrom: Denys Vlasenko <vda.linux@go=
oglemail.com>=0ATo: Mahmood Naderan <nt_mahmood@yahoo.com>=0ACc: David Rien=
tjes <rientjes@google.com>; Randy Dunlap <rdunlap@xenotime.net>; ""linux-ke=
rnel@vger.kernel.org"" <linux-kernel@vger.kernel.org>; ""linux-mm@kvack.org=
"" <linux-mm@kvack.org>=0ASent: Thursday, August 11, 2011 10:08 PM=0ASubjec=
t: Re: running of out memory =3D> kernel crash=0A=0AOn Thursday 11 August 2=
011 17:13, Mahmood Naderan wrote:=0A> >What it can possibly do if there is =
no swap and therefore it =0A> =0A> >can't free memory by writing out RAM pa=
ges to swap?=0A> =0A> =0A> >the disk activity comes from constant paging in=
 (reading)=0A> >of pages which contain code of running binaries.=0A> =0A> W=
hy the disk activity does not appear in the first scenario?=0A=0ABecause th=
ere is nowhere to write dirty pages in order to free=0Asome RAM (since you =
have no swap) and reading in more stuff=0Afrom disk can't possibly help wit=
h freeing RAM.=0A=0A(What kernel does in order to free RAM is it drops unmo=
dified=0Afile-backed pages, and doing _that_ doesn't require disk I/O).=0A=
=0AThus, no reading and no writing is necessary/possible.=0A=0A=0A> >Thus t=
he only option is to find some not recently used page=0A> > with read-only,=
 file-backed content (usually some binary's =0A> =0A> >text page, but can b=
e any read-only file mapping) and reuse it.=0A> Why "killing" does not appe=
ar here? Why it try to "find some =0A> =0A> recently used page"?=0A=0ABecau=
se killing is the last resort. As long as kernel can free=0Aa page by dropp=
ing an unmodified file-backed page, it will do that.=0AWhen there is nothin=
g more to drop, and still more free pages=0Aare needed, _then_ kernel will =
start oom killing.=0A=0A-- =0Avda=0A

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
