Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 1E8F36B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 09:42:22 -0400 (EDT)
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com> <CAFLxGvwJCMoiXFn3OgwiX+B50FTzGZmo6eG3xQ1KaPsEVZVA1g@mail.gmail.com> <1334490429.67558.YahooMailNeo@web162006.mail.bf1.yahoo.com> <CAFLxGvz5tmEi-39CZbJN+0zNd3ZpHXzZcNSFUpUWS_aMDJ4t6Q@mail.gmail.com> <20120418211032.47b243da@pyramind.ukuu.org.uk>
Message-ID: <1334842941.92324.YahooMailNeo@web162006.mail.bf1.yahoo.com>
Date: Thu, 19 Apr 2012 06:42:21 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: [NEW]: Introducing shrink_all_memory from user space
In-Reply-To: <20120418211032.47b243da@pyramind.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>

=0A>________________________________=0A>From: Alan Cox <alan@lxorguk.ukuu.o=
rg.uk>=0A>To: richard -rw- weinberger <richard.weinberger@gmail.com>=A0 =0A=
>Sent: Thursday, 19 April 2012 1:40 AM=0A>Subject: Re: [NEW]: Introducing s=
hrink_all_memory from user space=0A>=0A>On Sun, 15 Apr 2012 14:10:00 +0200=
=0A>richard -rw- weinberger <richard.weinberger@gmail.com> wrote:=0A>=0A>> =
On Sun, Apr 15, 2012 at 1:47 PM, PINTU KUMAR <pintu_agarwal@yahoo.com> wrot=
e:=0A>> > Moreover, this is mainly meant for mobile phones where there is o=
nly *one* user.=0A>> =0A>> I see. Jet another awful hack.=0A>> Mobile phone=
s are nothing special. They are computers=0A>=0A>Correct - so if it is show=
ing up useful situations then they are also=0A>useful beyond mobile phone.=
=0A>=0A>> Every program which is allowed to use this interface will (ab)use=
 it.=0A>=0A>If you expose it to userspace then you would want it very tight=
ly=0A>controlled and very much special case. Within the kernel using it=0A>=
internally within things like CMA allocators seems to make more sense.=0A>=
=0A>I think you overestimate the abuse. It's an interface which pushes clea=
n=0A>pages that can be cheaply recovered out of memory. It doesn't guarante=
e=0A>the caller reaps the benefit of that, and the vm will continue to try =
and=0A>share out any new resource fairly.=0A>=0A>Alan=0A=0ADear Alan, thank=
 you very much for your comments and suggestion.=0AMy plan is to develop a =
kind of system utility (like defragment) which we can run from user space (=
as root).=0A=A0=0AAnd yes you are right, my future plan is also to use it f=
or CMA as it also suffers from memory fragmentation.=0ANow I think CMA uses=
 memory compaction solution to reclaim pages for its allocation. Similarly =
we can use this on top of compaction for better results.=0A=A0=0AAnd we can=
 even call this from low memory notifier whenever memory pressure falls bel=
ow watermark and regain memory state as it was before.=0A=A0=0AWell more ex=
periments and findings are in progress.=0A=A0=0A=A0=0A=A0=0AThanks,=0APintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
