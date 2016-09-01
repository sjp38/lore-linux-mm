Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 20D3E6B0253
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 09:59:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m139so38523282wma.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 06:59:24 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id h127si2909697lfd.308.2016.09.01.06.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 06:59:22 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id 33so4170921lfw.3
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 06:59:22 -0700 (PDT)
Date: Thu, 1 Sep 2016 16:59:20 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCHv4 6/6] x86/signal: add SA_{X32,IA32}_ABI sa_flags
Message-ID: <20160901135920.GL23045@uranus.lan>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com>
 <20160831135936.2281-7-dsafonov@virtuozzo.com>
 <CAJwJo6YZEN75XB8YaMS26rbFAR0x77B-gfLKv37ib_eB_OLMBg@mail.gmail.com>
 <20160901122744.GA7438@redhat.com>
 <20160901124522.GK23045@uranus.lan>
 <CAJwJo6aL5vG1k=WTtBJQZeD5esUU=6StiTPtYxLAt5Q40xDMOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJwJo6aL5vG1k=WTtBJQZeD5esUU=6StiTPtYxLAt5Q40xDMOg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <0x7f454c46@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, X86 ML <x86@kernel.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On Thu, Sep 01, 2016 at 04:47:23PM +0300, Dmitry Safonov wrote:
> Thanks for your replies Oleg, Cyrill,
> 
> 2016-09-01 15:45 GMT+03:00 Cyrill Gorcunov <gorcunov@gmail.com>:
> > On Thu, Sep 01, 2016 at 02:27:44PM +0200, Oleg Nesterov wrote:
> >> > Hi Oleg,
> >> > can I have your acks or reviewed-by tags for 4-5-6 patches in the series,
> >> > or there is something left to fix?
> >>
> >> Well yes... Although let me repeat, I am not sure I personally like
> >> the very idea of 3/6 and 6/6. But as I already said I do not feel I
> >> understand the problem space enough, so I won't argue.
> >>
> >> However, let me ask again. Did you consider another option? Why criu
> >> can't exec a dummy 32-bit binary before anything else?
> >
> > I'm not really sure how this would look then. If I understand you
> > correctly you propose to exec dummy 32bit during "forking" stage
> > where we're recreating a process tree, before anything else. If
> > true this implies that we will need two criu engines: one compiled
> > with 64 bit and (same) second but compiled with 32 bits, no?
> 
> Yep, we would need then full CRIU, but compiled in 32 bits.
> And it can be then even more complicated, as 64-bit parent
> can have 32-bit child, which can have 64-bit child... et cetera.

Yup, this gonna be a mess, that's why I asked, because I suspect
Oleg meant something else maybe?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
