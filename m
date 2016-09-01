Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 44A8D6B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 08:45:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u81so60963626wmu.3
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 05:45:26 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id k69si2618632lfe.1.2016.09.01.05.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 05:45:25 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id e198so1856118lfb.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 05:45:24 -0700 (PDT)
Date: Thu, 1 Sep 2016 15:45:22 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCHv4 6/6] x86/signal: add SA_{X32,IA32}_ABI sa_flags
Message-ID: <20160901124522.GK23045@uranus.lan>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com>
 <20160831135936.2281-7-dsafonov@virtuozzo.com>
 <CAJwJo6YZEN75XB8YaMS26rbFAR0x77B-gfLKv37ib_eB_OLMBg@mail.gmail.com>
 <20160901122744.GA7438@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160901122744.GA7438@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, X86 ML <x86@kernel.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On Thu, Sep 01, 2016 at 02:27:44PM +0200, Oleg Nesterov wrote:
> > Hi Oleg,
> > can I have your acks or reviewed-by tags for 4-5-6 patches in the series,
> > or there is something left to fix?
> 
> Well yes... Although let me repeat, I am not sure I personally like
> the very idea of 3/6 and 6/6. But as I already said I do not feel I
> understand the problem space enough, so I won't argue.
> 
> However, let me ask again. Did you consider another option? Why criu
> can't exec a dummy 32-bit binary before anything else?

I'm not really sure how this would look then. If I understand you
correctly you propose to exec dummy 32bit during "forking" stage
where we're recreating a process tree, before anything else. If
true this implies that we will need two criu engines: one compiled
with 64 bit and (same) second but compiled with 32 bits, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
