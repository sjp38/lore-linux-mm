Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4256C6B30E8
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:06:24 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id r11so1255726wmg.1
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:06:24 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u83si5994166wmb.83.2018.11.23.03.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 23 Nov 2018 03:06:23 -0800 (PST)
Date: Fri, 23 Nov 2018 12:06:11 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181123110611.s2gmd237j7docrxt@linutronix.de>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
 <20181123110226.GA5125@andrea>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181123110226.GA5125@andrea>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Parri <andrea.parri@amarulasolutions.com>, Peter Zijlstra <peterz@infradead.org>
Cc: zhe.he@windriver.com, catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, boqun.feng@gmail.com

On 2018-11-23 12:02:55 [+0100], Andrea Parri wrote:
> > is this an RT-only problem? Because mainline should not allow read->read
> > locking or read->write locking for reader-writer locks. If this only
> > happens on v4.18 and not on v4.19 then something must have fixed it.
> 
> Probably misunderstanding, but I'd say that read->read locking is "the
> norm"...?
> 
> If you don't use qrwlock, readers are also "recursive", in part.,
> 
>   P0			P1
>   read_lock(l)
> 			write_lock(l)
>   read_lock(l)
> 
> won't block P0 on the second read_lock().  (qrwlock somehow complicate
> the analysis; IIUC, they are recursive if and only if in_interrupt().).

ehm, peterz, is that true? My memory on that is that all readers will
block if there is a writer pending.

>   Andrea

Sebastian
