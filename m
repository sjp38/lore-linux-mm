Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id D0A2A6B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 14:49:01 -0400 (EDT)
References: <1370843475.58124.YahooMailNeo@web160106.mail.bf1.yahoo.com> <CAK7N6vrQFK=9OQi7dDUgGWWNQk71x3BeqPA9x3Pq66baA61PrQ@mail.gmail.com>
Message-ID: <1370890140.99216.YahooMailNeo@web160102.mail.bf1.yahoo.com>
Date: Mon, 10 Jun 2013 11:49:00 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: [checkpatch] - Confusion
In-Reply-To: <CAK7N6vrQFK=9OQi7dDUgGWWNQk71x3BeqPA9x3Pq66baA61PrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: anish singh <anish198519851985@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>________________________________=0A> From: anish singh <anish198519851985@=
gmail.com>=0A>To: PINTU KUMAR <pintu_agarwal@yahoo.com> =0A>Cc: "linux-kern=
el@vger.kernel.org" <linux-kernel@vger.kernel.org>; "linux-mm@kvack.org" <l=
inux-mm@kvack.org> =0A>Sent: Sunday, 9 June 2013 10:58 PM=0A>Subject: Re: [=
checkpatch] - Confusion=0A> =0A>=0A>On Mon, Jun 10, 2013 at 11:21 AM, PINTU=
 KUMAR <pintu_agarwal@yahoo.com> wrote:=0A>> Hi,=0A>>=0A>> I wanted to subm=
it my first patch.=0A>> But I have some confusion about the /scripts/checkp=
atch.pl errors.=0A>>=0A>> After correcting some checkpatch errors, when I r=
un checkpatch.pl, it showed me 0 errors.=0A>> But when I create patches are=
 git format-patch, it is showing me 1 error.=0A>did=A0 you run the checkpat=
ch.pl on the file which gets created=0A>after git format-patch?=0A>If yes, =
then I think it is not necessary.You can use git-am to apply=0A>your own pa=
tch on a undisturbed file and if it applies properly then=0A>you are good t=
o go i.e. you can send your patch.=0A=0AYes, first I ran checkpatch directl=
y on the file(mm/page_alloc.c) and fixed all the errors.=0AIt showed me (0)=
 errors.=0AThen I created a patch using _git format-patch_ and ran checkpat=
ch again on the created patch.=0ABut now it is showing me 1 error.=0AAccord=
ing to me this error is false positive (irrelevant), because I did not chan=
ge anything related to the error and also the similar change already exists=
 somewhere else too.=0ADo you mean, shall I go ahead and submit the patch w=
ith this 1 error??=0AERROR: need consistent spacing around '*' (ctx:WxV)=0A=
=0A#153: FILE: mm/page_alloc.c:5476:=0A+int min_free_kbytes_sysctl_handler(=
ctl_table *table, int write,=0A=0A=0A=0A>>=0A>> If I fix error in patch, it=
 showed me back again in files.=0A>>=0A>> Now, I am confused which error to=
 fix while submitting patches, the file or the patch errors.=0A>>=0A>> Plea=
se provide your opinion.=0A>>=0A>> File: mm/page_alloc.c=0A>> Previous file=
 errors:=0A>> total: 16 errors, 110 warnings, 6255 lines checked=0A>>=0A>> =
After fixing errors:=0A>> total: 0 errors, 105 warnings, 6255 lines checked=
=0A>>=0A>>=0A>> And, after running on patch:=0A>> ERROR: need consistent sp=
acing around '*' (ctx:WxV)=0A>> #153: FILE: mm/page_alloc.c:5476:=0A>> +int=
 min_free_kbytes_sysctl_handler(ctl_table *table, int write,=0A>>=0A>>=0A>>=
=0A>>=0A>> - Pintu=0A>> --=0A>> To unsubscribe from this list: send the lin=
e "unsubscribe linux-kernel" in=0A>> the body of a message to majordomo@vge=
r.kernel.org=0A>> More majordomo info at=A0 http://vger.kernel.org/majordom=
o-info.html=0A>> Please read the FAQ at=A0 http://www.tux.org/lkml/=0A>=0A>=
--=0A>To unsubscribe, send a message with 'unsubscribe linux-mm' in=0A>the =
body to majordomo@kvack.org.=A0 For more info on Linux MM,=0A>see: http://w=
ww.linux-mm.org/ .=0A>Don't email: <a href=3Dmailto:"dont@kvack.org"> email=
@kvack.org </a>=0A>=0A>=0A>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
