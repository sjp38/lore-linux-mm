Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 989936B004D
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 05:16:40 -0400 (EDT)
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com> <CAFLxGvwJCMoiXFn3OgwiX+B50FTzGZmo6eG3xQ1KaPsEVZVA1g@mail.gmail.com> <1334490429.67558.YahooMailNeo@web162006.mail.bf1.yahoo.com> <CAFLxGvz5tmEi-39CZbJN+0zNd3ZpHXzZcNSFUpUWS_aMDJ4t6Q@mail.gmail.com>
Message-ID: <1334567799.97554.YahooMailNeo@web162006.mail.bf1.yahoo.com>
Date: Mon, 16 Apr 2012 02:16:39 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: [NEW]: Introducing shrink_all_memory from user space
In-Reply-To: <CAFLxGvz5tmEi-39CZbJN+0zNd3ZpHXzZcNSFUpUWS_aMDJ4t6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>

=0A=0A> From: richard -rw- weinberger <richard.weinberger@gmail.com>=0A> Se=
nt: Sunday, 15 April 2012 5:40 PM=0A=0A> Every program which is allowed to =
use this interface will (ab)use it.=0A> Anyway, by exposing this interface =
to user space (or kernel modules)=0A> you'll confuse the VM system.=0A=0ADe=
ar Richard, thank you very much for all your feedbacks.=0AI can see that yo=
u forsee many problems in doing that (even as root) =0Aand in just one prog=
ram as part of system utility.=0AI am sorry but if you can highlight few pr=
oblems here it will be=0Ahelpful for me(and others) to understand.=0AAlso I=
 wanted to understand, why it is meant only for Hibernation?=0A=0AThank you=
 so much !=0A=0A=0ARegards,=0APintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
