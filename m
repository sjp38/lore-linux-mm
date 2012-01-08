Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B7D4C6B0069
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 11:32:55 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so2722303vbb.14
        for <linux-mm@kvack.org>; Sun, 08 Jan 2012 08:32:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326040026-7285-1-git-send-email-gilad@benyossef.com>
References: <1326040026-7285-1-git-send-email-gilad@benyossef.com>
Date: Sun, 8 Jan 2012 18:32:53 +0200
Message-ID: <CAOtvUMcU95A-WVmTuRNe=3Qvy+VHvD7S=+JGQbsAkKa+Z_3eoQ@mail.gmail.com>
Subject: Re: [PATCH v6 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>

<SNIP>
> CC: Michal Nazarewicz <mina86@mina86.org>
> CC: Kosaki Motohiro <kosaki.motohiro@gmail.com>
>

Damn... I've messed up Michael email address. Sorry about that.
Resending the right address now :-(

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
