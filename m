Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 696F56B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 05:06:14 -0500 (EST)
Received: by ghrr17 with SMTP id r17so4893797ghr.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 02:06:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1111150951140.22502@router.home>
References: <1321179449-6675-1-git-send-email-gilad@benyossef.com>
	<1321179449-6675-2-git-send-email-gilad@benyossef.com>
	<alpine.DEB.2.00.1111150951140.22502@router.home>
Date: Tue, 22 Nov 2011 12:06:11 +0200
Message-ID: <CAOtvUMcbMTSRhmc5N=jTVN2LMowoz3Wy5kdy9e1Y07LtV6bSUg@mail.gmail.com>
Subject: Re: [PATCH v3 1/5] smp: Introduce a generic on_each_cpu_mask function
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

On Tue, Nov 15, 2011 at 5:51 PM, Christoph Lameter <cl@linux.com> wrote:
> On Sun, 13 Nov 2011, Gilad Ben-Yossef wrote:
>
>> on_each_cpu_mask calls a function on processors specified my cpumask,
>> which may include the local processor.
>
> Reviewed-by: Christoph Lameter <cl@linux.com>
>

Thanks :-)

v4 is on the way.

Gilad


-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
