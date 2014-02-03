Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 15C6F6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 17:34:44 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so7663758pab.4
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 14:34:43 -0800 (PST)
Received: from qmta14.westchester.pa.mail.comcast.net (qmta14.westchester.pa.mail.comcast.net. [2001:558:fe14:44:76:96:59:212])
        by mx.google.com with ESMTP id i8si22130941pav.16.2014.02.03.14.34.42
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 14:34:43 -0800 (PST)
Date: Mon, 3 Feb 2014 16:34:40 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Kernel WARNING splat in 3.14-rc1
In-Reply-To: <alpine.DEB.2.02.1402031236250.7898@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1402031634230.5527@nuc>
References: <52EFF658.2080001@lwfinger.net> <alpine.DEB.2.02.1402031236250.7898@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Larry Finger <Larry.Finger@lwfinger.net>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 3 Feb 2014, David Rientjes wrote:

> Commit c65c1877bd68 ("slub: use lockdep_assert_held") incorrectly required
> that add_full() and remove_full() hold n->list_lock.  The lock is only
> taken when kmem_cache_debug(s), since that's the only time it actually
> does anything.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
