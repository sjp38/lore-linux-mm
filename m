Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0F2B6B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:42:18 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g25so2302437lfh.13
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:42:18 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id r76si5326181lfi.366.2017.07.25.02.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 02:42:17 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id 65so552103lfa.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:42:17 -0700 (PDT)
Reply-To: alex.popov@linux.com
Subject: Re: [v3] mm: Add SLUB free list pointer obfuscation
From: Alexander Popov <alex.popov@linux.com>
References: <20170706002718.GA102852@beast>
 <cdd42a1b-ce15-df8c-6bd1-b0943275986f@linux.com>
Message-ID: <2a30f7bf-601b-f442-9664-7de5a1501206@linux.com>
Date: Tue, 25 Jul 2017 12:42:12 +0300
MIME-Version: 1.0
In-Reply-To: <cdd42a1b-ce15-df8c-6bd1-b0943275986f@linux.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, alex.popov@linux.com

