Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8BE456001DA
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 02:37:07 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 22so219726fge.8
        for <linux-mm@kvack.org>; Mon, 18 Jan 2010 23:37:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100119071734.GG14345@redhat.com>
References: <20100118133755.GG30698@redhat.com>
	 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
	 <20100118141938.GI30698@redhat.com>
	 <84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
	 <20100118170816.GA22111@redhat.com>
	 <84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
	 <20100118181942.GD22111@redhat.com>
	 <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
	 <20100119071734.GG14345@redhat.com>
Date: Tue, 19 Jan 2010 09:37:05 +0200
Message-ID: <84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Gleb,

On Tue, Jan 19, 2010 at 9:17 AM, Gleb Natapov <gleb@redhat.com> wrote:
> The thread took a direction of bashing mlockall(). This is especially
> strange since proposed patch actually makes mlockall() more fine
> grained and thus more useful.

No, the thread took a direction of you not being able to properly
explain why we want MMAP_UNLOCKED in the kernel. It seems useless for
real-time and I've yet to figure out why you need _mlockall()_ if it's
a performance thing.

It would be probably useful if you could point us to the application
source code that actually wants this feature.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
