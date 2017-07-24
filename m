Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEB66B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 17:17:18 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 42so24397216lfq.10
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 14:17:18 -0700 (PDT)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id d188si4584860lfd.181.2017.07.24.14.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 14:17:16 -0700 (PDT)
Received: by mail-lf0-f65.google.com with SMTP id k82so7578206lfg.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 14:17:16 -0700 (PDT)
Reply-To: alex.popov@linux.com
Subject: Re: [v3] mm: Add SLUB free list pointer obfuscation
References: <20170706002718.GA102852@beast>
From: Alexander Popov <alex.popov@linux.com>
Message-ID: <cdd42a1b-ce15-df8c-6bd1-b0943275986f@linux.com>
Date: Tue, 25 Jul 2017 00:17:11 +0300
MIME-Version: 1.0
In-Reply-To: <20170706002718.GA102852@beast>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

