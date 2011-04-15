Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BBA66900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:12:40 -0400 (EDT)
Received: by bwz17 with SMTP id 17so3573464bwz.14
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:12:36 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 0/1] mm: make read-only accessors take const pointer
 parameters
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com>
 <20110415145133.GO15707@random.random>
 <20110415155916.GD7112@esdhcp04044.research.nokia.com>
Date: Fri, 15 Apr 2011 18:12:33 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vtzly7dk3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <20110415155916.GD7112@esdhcp04044.research.nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ext Andrea Arcangeli <aarcange@redhat.com>, Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: akpm@linux-foundation.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 15 Apr 2011 17:59:16 +0200, Phil Carmody wrote:
> I'm just glad this wasn't an insta-nack, as I am quite a fan of
> consts, and hopefully something can be worked out.

I feel you man.  Unfortunately, I think that const, since it's an
after-thought, is not very usable in C.

For instance, as you've pointed in your patch, the "_ro" suffix
is sort of dumb, but without it compound_head would have to take
const and return non-const (like strchr() does) which is kinda
stupid as well.

What's more, because of lack of encapsulation, =E2=80=9Cconst struct pag=
e=E2=80=9D
only means that the object is const but thighs it points to aren't.
As such, const does not really play that well with structs anyway.

const is, in my opinion, one of those things C++ actually got
right (or close to right).

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
