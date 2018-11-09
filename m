Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62A446B0730
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 18:06:10 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s22so2191467pgv.8
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 15:06:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k15si7279690pgi.99.2018.11.09.15.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 15:06:09 -0800 (PST)
Date: Fri, 9 Nov 2018 15:06:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/swap: Access struct pagevec remotely
Message-Id: <20181109150605.1e5d765b6d7a12edf9bb26e5@linux-foundation.org>
In-Reply-To: <20180914145924.22055-3-bigeasy@linutronix.de>
References: <20180914145924.22055-1-bigeasy@linutronix.de>
	<20180914145924.22055-3-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Vlastimil Babka <vbabka@suse.cz>, frederic@kernel.org

On Fri, 14 Sep 2018 16:59:24 +0200 Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> Now that struct pagevec is locked during access, it is possible to
> access it from a remote CPU. The advantage is that the work can be done
> from the "requesting" CPU without firing a worker on a remote CPU and
> waiting for it to complete the work.

Well, removing a deferred work thingy is always welcome.  But I'm not
sure this was the overall aim of the patchset.  In fact I'm somewhat
unclear on what the overall aim is.  Does it have some relevance to -RT
kernels?

Anyway, please see if you can clarify the high-level intent, refresh,
retest and resend?
