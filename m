Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D3A1B8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 06:20:54 -0400 (EDT)
Received: by fxm18 with SMTP id 18so5002886fxm.14
        for <linux-mm@kvack.org>; Mon, 11 Apr 2011 03:20:52 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 1/2] break out page allocation warning code
References: <20110408202253.6D6D231C@kernel>
 <BANLkTi=OnDX53nOZcaaMmqXRBcWicam0xg@mail.gmail.com>
 <1302296522.7286.1197.camel@nimitz>
Date: Mon, 11 Apr 2011 12:20:49 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vtrq0zac3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1302296522.7286.1197.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <mnazarewicz@gmail.com>, Dave
 Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

>> On Apr 8, 2011 10:23 PM, "Dave Hansen" <dave@linux.vnet.ibm.com> wrot=
e:
>>> +       if (fmt) {
>>> +               printk(KERN_WARNING);
>>> +               va_start(args, fmt);
>>> +               r =3D vprintk(fmt, args);
>>> +               va_end(args);
>>> +       }

> On Fri, 2011-04-08 at 22:54 +0200, Micha=C5=82 Nazarewicz wrote:
>> Could we make the "printk(KERN_WARNING);" go away and require caller
>> to specify level?

On Fri, 08 Apr 2011 23:02:02 +0200, Dave Hansen wrote:
> The core problem is this: I want two lines of output: one for the
> order/mode gunk, and one for the user-specified message.
>
> If we have the user pass in a string for the printk() level, we're stu=
ck
> doing what I have here.  If we have them _prepend_ it to the "fmt"
> string, then it's harder to figure out below.  I guess we could fish i=
n
> the string for it.

This is a bit unfortunate, but that's what I was worried anyway.  I gues=
s
creating a macro which automatically prepends format  with KERN_WARNING
would solve the issue but that's probably not the most elegant solution.=


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
