Received: by wa-out-1112.google.com with SMTP id j37so115376waf.22
        for <linux-mm@kvack.org>; Fri, 05 Dec 2008 16:32:31 -0800 (PST)
Message-ID: <208aa0f00812051632h38fc0a5g58d233190436cc90@mail.gmail.com>
Date: Fri, 5 Dec 2008 16:32:30 -0800
From: "Edward Estabrook" <edward.estabrook.lkml@gmail.com>
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
In-Reply-To: <20081205094447.GA3081@local>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <43FC624C55D8C746A914570B66D642610367F29B@cos-us-mb03.cos.agilent.com>
	 <1228379942.5092.14.camel@twins> <20081204180809.GB3079@local>
	 <1228461060.18899.8.camel@twins> <20081205094447.GA3081@local>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Hans J. Koch" <hjk@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, edward_estabrook@agilent.com, linux-kernel@vger.kernel.org, gregkh@suse.de, edward.estabrook@gmail.com, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

> Well, UIO already rapes the mmap interface by using the "offset" parameter to
> pass in the number of the mapping.

Exactly.

> But I'll NAK the current concept, too. It's a UIO kernel driver's task to tell
> userspace which memory a device has to offer. The UIO core prevents userspace
> as much as possible from mapping anything different. And it should stay that
> way.

The ultimate purpose (I thought) of the UIO driver is to simplify
driver development
by pushing device control into userspace.  There is a very real need
for efficient
dynamic control over the DMA allocation of a device.  Why not 'allow' this to
happen in userspace if it can be done safely and without breaking anything else?

Remember that for devices employing ring buffers it is not a question of
'how much memory a device has to offer' but rather 'how much system
memory would the
driver like to configure that device to use'.

I don't want to stop my DMA engine and reload the driver to create
more buffers (and I don't
want to pre-allocate more than I need as contingency).

Cheers,
Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
