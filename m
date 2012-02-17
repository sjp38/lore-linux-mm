Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id CE1896B00F4
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 10:15:14 -0500 (EST)
Message-ID: <1329491708.2293.277.camel@twins>
Subject: Re: [PATCH 1/2] rmap: Staticize page_referenced_file and
 page_referenced_anon
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 17 Feb 2012 16:15:08 +0100
In-Reply-To: <1329488869-7270-1-git-send-email-consul.kautuk@gmail.com>
References: <1329488869-7270-1-git-send-email-consul.kautuk@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-02-17 at 09:27 -0500, Kautuk Consul wrote:
> Staticize the page_referenced_anon and page_referenced_file
> functions.
> These functions are called only from page_referenced.

Subject and changelog say: staticize, which I read to mean: make static.
Yet what the patch does is make them inline ?!?

Also, if they're static and there's only a single callsite, gcc will
already inline them, does this patch really make a difference?

> -static int page_referenced_anon(struct page *page,
> +static inline int page_referenced_anon(struct page *page,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
