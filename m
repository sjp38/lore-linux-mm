Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ED6C46B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 10:52:00 -0500 (EST)
Date: Tue, 15 Nov 2011 09:51:56 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 1/5] smp: Introduce a generic on_each_cpu_mask
 function
In-Reply-To: <1321179449-6675-2-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.DEB.2.00.1111150951140.22502@router.home>
References: <1321179449-6675-1-git-send-email-gilad@benyossef.com> <1321179449-6675-2-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

On Sun, 13 Nov 2011, Gilad Ben-Yossef wrote:

> on_each_cpu_mask calls a function on processors specified my cpumask,
> which may include the local processor.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
