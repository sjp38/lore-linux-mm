Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0216B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 19:35:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r81-v6so21700413pfk.11
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 16:35:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 202-v6si12582198pfz.227.2018.10.15.16.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 16:35:31 -0700 (PDT)
Date: Mon, 15 Oct 2018 16:35:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/kasan: make quarantine_lock a raw_spinlock_t
Message-Id: <20181015163529.30ed9b0ac18e20dd975f4253@linux-foundation.org>
In-Reply-To: <20181013135058.GC4931@worktop.programming.kicks-ass.net>
References: <20181005163320.zkacovxvlih6blpp@linutronix.de>
	<CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
	<20181009142742.ikh7xv2dn5skjjbe@linutronix.de>
	<CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
	<20181010092929.a5gd3fkkw6swco4c@linutronix.de>
	<CACT4Y+agGPSTZ-8A8r8haSeRM8UpRYMAF8BC4A87yeM9nvpP6w@mail.gmail.com>
	<20181010095343.6qxved3owi6yokoa@linutronix.de>
	<CACT4Y+ZpMjYBPS0GHP0AsEJZZmDjwV9DJBiVUzYKBnD+r9W4+A@mail.gmail.com>
	<20181010214945.5owshc3mlrh74z4b@linutronix.de>
	<20181012165655.f067886428a394dc7fbae7af@linux-foundation.org>
	<20181013135058.GC4931@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

On Sat, 13 Oct 2018 15:50:58 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> The whole raw_spinlock_t is for RT, no other reason.

Oh.  I never realised that.

Is this documented anywhere?  Do there exist guidelines which tell
non-rt developers and reviewers when it should be used?
