Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 08E5F6B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 12:49:40 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D686482C1C9
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 12:53:19 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fOjGLMdSCGcy for <linux-mm@kvack.org>;
	Tue,  6 Oct 2009 12:53:13 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1D57882C3BE
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 12:53:12 -0400 (EDT)
Date: Tue, 6 Oct 2009 12:43:33 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 4/4] vunmap: Fix racy use of rcu_head
In-Reply-To: <20091006144043.378971387@polymtl.ca>
Message-ID: <alpine.DEB.1.10.0910061241250.18309@gentwo.org>
References: <20091006143727.868480435@polymtl.ca> <20091006144043.378971387@polymtl.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: nickpiggin@yahoo.com.au, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Oct 2009, Mathieu Desnoyers wrote:

> Simplest fix: directly kfree the data structure rather than doing it lazily.

The delay is necessary as far as I can tell for performance reasons. But
Nick was the last one fiddling around with the subsystem as far as I
remember. CCing him. May be he has a minute to think about a fix that
preserved performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
