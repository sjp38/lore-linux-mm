Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB226B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 14:13:20 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so26693587igc.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 11:13:20 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id no4si7270964igb.49.2015.09.10.11.13.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 11:13:19 -0700 (PDT)
Date: Thu, 10 Sep 2015 13:13:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <CACT4Y+Y7hjhbhDoDC-gJaqQcaw0jACjvaaqjFeemvWPV=RjPRw@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509101312470.10226@east.gentwo.org>
References: <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org> <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com> <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org> <20150909184415.GJ4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org>
 <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com> <20150910171333.GD4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509101301010.10131@east.gentwo.org> <CACT4Y+Y7hjhbhDoDC-gJaqQcaw0jACjvaaqjFeemvWPV=RjPRw@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, 10 Sep 2015, Dmitry Vyukov wrote:

> On Thu, Sep 10, 2015 at 8:01 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Thu, 10 Sep 2015, Paul E. McKenney wrote:
> >
> >> The reason we poked at this was to see if any of SLxB touched the
> >> memory being freed.  If none of them touched the memory being freed,
> >> and if that was a policy, then the idiom above would be legal.  However,
> >> one of them does touch the memory being freed, so, yes, the above code
> >> needs to be fixed.
> >
> > The one that touches the object has a barrier() before it touches the
> > memory.
>
> It does not change anything, right?

It changes the first word of the object after the barrier. The first word
is used in SLUB as the pointer to the next free object.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
