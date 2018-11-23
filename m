Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF9E56B30E3
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:03:04 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id q8so451815edd.8
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:03:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t21-v6sor6960561ejx.10.2018.11.23.03.03.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 03:03:03 -0800 (PST)
Date: Fri, 23 Nov 2018 12:02:55 +0100
From: Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181123110226.GA5125@andrea>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123095314.hervxkxtqoixovro@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: zhe.he@windriver.com, catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, boqun.feng@gmail.com

> is this an RT-only problem? Because mainline should not allow read->read
> locking or read->write locking for reader-writer locks. If this only
> happens on v4.18 and not on v4.19 then something must have fixed it.

Probably misunderstanding, but I'd say that read->read locking is "the
norm"...?

If you don't use qrwlock, readers are also "recursive", in part.,

  P0			P1
  read_lock(l)
			write_lock(l)
  read_lock(l)

won't block P0 on the second read_lock().  (qrwlock somehow complicate
the analysis; IIUC, they are recursive if and only if in_interrupt().).

  Andrea


>  
> 
> Sebastian
