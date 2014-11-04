Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAB96B00BF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 07:41:50 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id b6so3079630lbj.16
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 04:41:49 -0800 (PST)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com. [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id q1si644652laq.20.2014.11.04.04.41.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 04:41:49 -0800 (PST)
Received: by mail-la0-f52.google.com with SMTP id pv20so765224lab.25
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 04:41:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <771b3575.1fa3f.1495fe48476.Coremail.michaelbest002@126.com>
References: <771b3575.1fa3f.1495fe48476.Coremail.michaelbest002@126.com>
From: Mulyadi Santosa <mulyadi.santosa@gmail.com>
Date: Tue, 4 Nov 2014 19:41:08 +0700
Message-ID: <CAGdaadaxRn8yB3jWUKvyosnjHm133n5BnFX8rsaVm9-7Q+M1ZA@mail.gmail.com>
Subject: Re: Why page fault handler behaved this way? Please help!
Content-Type: multipart/alternative; boundary=001a11348490660a87050707c91d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?56em5byL5oiI?= <michaelbest002@126.com>
Cc: kernelnewbies <kernelnewbies@kernelnewbies.org>, linux-mm <linux-mm@kvack.org>

--001a11348490660a87050707c91d
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello...

how big is your binary anyway?

from your log, if my calculation is right, your code segment is around 330
KiB. But bear in mind, that not all of them are your code. There are other
code like PLT, function prefix and so on.

Also, even if your code is big, are you sure all of them are executed?
Following 20/80 principle, most of the time, when running an application,
only 20% portion of the application are really used/executed during 80% of
application lifetime. The rest, it might untouched at all.


On Thu, Oct 30, 2014 at 2:10 PM, =E7=A7=A6=E5=BC=8B=E6=88=88 <michaelbest00=
2@126.com> wrote:

>
>
>
> Dear all,
>
>
> I am a kernel newbie who want's to learn more about memory management.
> Recently I'm doing some experiment on page fault handler. There happened
> something that I couldn't understand.
>
>
> From reading the book Understanding the Linux Kernel, I know that the
> kernel loads a page as late as possible. It's only happened when the
> program has to reference  (read, write, or execute) a page yet the page i=
s
> not in memory.
>
>
> However, when I traced all page faults in my test program, I found
> something strange. My test program is large enough, but there are only tw=
o
> page faults triggered in the code segment of the program, while most of t=
he
> faults are not in code segment.
>
>
> At first I thought that perhaps the page is not the normal 4K page. Thus =
I
> turned off the PAE support in the config file. But the log remains
> unchanged.
>
>
> So why are there only 2 page faults in code segment? It shouldn't be like
> this in my opinion. Please help me.
>
>
> The attachment is my kernel log. Limited by the mail size, I couldn't
> upload my program, but I believe that the log is clear enough.
>
>
> Thank you very much.
> Best regards
>
>
> _______________________________________________
> Kernelnewbies mailing list
> Kernelnewbies@kernelnewbies.org
> http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies
>
>


--=20
regards,

Mulyadi Santosa
Freelance Linux trainer and consultant

blog: the-hydra.blogspot.com
training: mulyaditraining.blogspot.com

--001a11348490660a87050707c91d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div><div>Hello...<br><br></div>how big is your binar=
y anyway?<br><br></div>from your log, if my calculation is right, your code=
 segment is around 330 KiB. But bear in mind, that not all of them are your=
 code. There are other code like PLT, function prefix and so on.<br><br></d=
iv>Also, even if your code is big, are you sure all of them are executed? F=
ollowing 20/80 principle, most of the time, when running an application, on=
ly 20% portion of the application are really used/executed during 80% of ap=
plication lifetime. The rest, it might untouched at all.<br><br></div><div =
class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Thu, Oct 30, 2014 a=
t 2:10 PM, =E7=A7=A6=E5=BC=8B=E6=88=88 <span dir=3D"ltr">&lt;<a href=3D"mai=
lto:michaelbest002@126.com" target=3D"_blank">michaelbest002@126.com</a>&gt=
;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex"><br>
<br>
<br>
Dear all,<br>
<br>
<br>
I am a kernel newbie who want&#39;s to learn more about memory management. =
Recently I&#39;m doing some experiment on page fault handler. There happene=
d something that I couldn&#39;t understand.<br>
<br>
<br>
>From reading the book Understanding the Linux Kernel, I know that the kerne=
l loads a page as late as possible. It&#39;s only happened when the program=
 has to reference=C2=A0=C2=A0(read, write, or execute)=C2=A0a page yet the =
page is not in memory.<br>
<br>
<br>
However, when I traced all page faults in my test program, I found somethin=
g strange. My test program is large enough, but there are only two page fau=
lts triggered in the code segment of the program, while most of the faults =
are not in code segment.<br>
<br>
<br>
At first I thought that perhaps the page is not the normal 4K page. Thus I =
turned off the PAE support in the config file. But the log remains unchange=
d.<br>
<br>
<br>
So why are there only 2 page faults in code segment? It shouldn&#39;t be li=
ke this in my opinion. Please help me.<br>
<br>
<br>
The attachment is my kernel log. Limited by the mail size, I couldn&#39;t u=
pload my program, but I believe that the log is clear enough.<br>
<br>
<br>
Thank you very much.<br>
Best regards<br>
<br>
<br>_______________________________________________<br>
Kernelnewbies mailing list<br>
<a href=3D"mailto:Kernelnewbies@kernelnewbies.org">Kernelnewbies@kernelnewb=
ies.org</a><br>
<a href=3D"http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies" t=
arget=3D"_blank">http://lists.kernelnewbies.org/mailman/listinfo/kernelnewb=
ies</a><br>
<br></blockquote></div><br><br clear=3D"all"><br>-- <br><div class=3D"gmail=
_signature">regards,<br><br>Mulyadi Santosa<br>Freelance Linux trainer and =
consultant<br><br>blog: <a href=3D"http://the-hydra.blogspot.com">the-hydra=
.blogspot.com</a><br>training: <a href=3D"http://mulyaditraining.blogspot.c=
om">mulyaditraining.blogspot.com</a></div>
</div>

--001a11348490660a87050707c91d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
