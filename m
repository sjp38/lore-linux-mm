Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id DF2DB6B0082
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 16:59:34 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so3685187pbc.14
        for <linux-mm@kvack.org>; Thu, 16 Feb 2012 13:59:34 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 01/18] Added hacking menu for override optimization by
 GCC.
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
 <op.v9sctsrj3l0zgt@mpn-glaptop>
 <76ede790fcc4ab73f969761034554e92@rsmogura.net>
Date: Thu, 16 Feb 2012 13:59:29 -0800
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v9skpfhq3l0zgt@mpn-glaptop>
In-Reply-To: <76ede790fcc4ab73f969761034554e92@rsmogura.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?UmFkb3PFgmF3IFNtb2d1cmE=?= <mail@smogura.eu>
Cc: linux-mm@kvack.org, Yongqiang Yang <xiaoqiangnk@gmail.com>, linux-ext4@vger.kernel.org

On Thu, 16 Feb 2012 12:26:00 -0800, Rados=C5=82aw Smogura <mail@smogura.=
eu> wrote:

> On Thu, 16 Feb 2012 11:09:18 -0800, Michal Nazarewicz wrote:
>> On Thu, 16 Feb 2012 06:31:28 -0800, Rados=C5=82aw Smogura
>> <mail@smogura.eu> wrote:
>>> Supporting files, like Kconfig, Makefile are auto-generated due to
>>> large amount
>>> of available options.
>>
>> So why not run the script as part of make rather then store generated=

>> files in
>> repository?
> Idea to run this script through make is quite good, and should work,
> because new mane will be generated before "config" starts.
>
> "Bashizms" are indeed unneeded, I will try to replace this with sed.

Uh? Why sed?

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
