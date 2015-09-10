Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 96F4C6B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 18:01:02 -0400 (EDT)
Received: by iofb144 with SMTP id b144so78143695iof.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 15:01:02 -0700 (PDT)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id qm8si95834igb.65.2015.09.10.15.00.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 15:00:58 -0700 (PDT)
Date: Thu, 10 Sep 2015 17:00:56 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
In-Reply-To: <CACT4Y+ZN=wPWtXOSKanWpL9OtRUd8Bd8r5_o3GJ92YHYgoT01g@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509101700240.11096@east.gentwo.org>
References: <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org> <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com> <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org> <20150909184415.GJ4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org>
 <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com> <20150910171333.GD4029@linux.vnet.ibm.com> <alpine.DEB.2.11.1509101301010.10131@east.gentwo.org> <CACT4Y+Y7hjhbhDoDC-gJaqQcaw0jACjvaaqjFeemvWPV=RjPRw@mail.gmail.com>
 <alpine.DEB.2.11.1509101312470.10226@east.gentwo.org> <CACT4Y+ZN=wPWtXOSKanWpL9OtRUd8Bd8r5_o3GJ92YHYgoT01g@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, 10 Sep 2015, Dmitry Vyukov wrote:

> > It changes the first word of the object after the barrier. The first word
> > is used in SLUB as the pointer to the next free object.
>
> User can also write to this object after it is reallocated. It is
> equivalent to kmalloc writing to the object.
> And barrier is not the kind of barrier that would make it correct.
> So I do not see how it is relevant.

This is a compiler barrier so nothing can be moved below that into the
code where the freelist pointer is handled. That was the issue from what
I heard?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
