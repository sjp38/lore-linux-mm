Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A4FD76B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 14:11:35 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so35099543wic.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:11:35 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id a4si20891556wjx.101.2015.09.10.11.11.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 11:11:34 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so32603301wic.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:11:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509101301010.10131@east.gentwo.org>
References: <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org> <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org> <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
 <20150910171333.GD4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509101301010.10131@east.gentwo.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 10 Sep 2015 20:11:14 +0200
Message-ID: <CACT4Y+Y7hjhbhDoDC-gJaqQcaw0jACjvaaqjFeemvWPV=RjPRw@mail.gmail.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, Sep 10, 2015 at 8:01 PM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 10 Sep 2015, Paul E. McKenney wrote:
>
>> The reason we poked at this was to see if any of SLxB touched the
>> memory being freed.  If none of them touched the memory being freed,
>> and if that was a policy, then the idiom above would be legal.  However,
>> one of them does touch the memory being freed, so, yes, the above code
>> needs to be fixed.
>
> The one that touches the object has a barrier() before it touches the
> memory.

It does not change anything, right?


--=20
Dmitry Vyukov, Software Engineer, dvyukov@google.com
Google Germany GmbH, Dienerstra=C3=9Fe 12, 80331, M=C3=BCnchen
Gesch=C3=A4ftsf=C3=BChrer: Graham Law, Christine Elizabeth Flores
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat
sind, leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
