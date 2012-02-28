Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id C5A596B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 03:49:55 -0500 (EST)
Received: by lamf4 with SMTP id f4so8813614lam.14
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 00:49:53 -0800 (PST)
Date: Tue, 28 Feb 2012 10:49:46 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 00/10] memcg: Kernel Memory Accounting.
In-Reply-To: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
Message-ID: <alpine.LFD.2.02.1202281043420.4106@tux.localdomain>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: cgroups@vger.kernel.org, suleiman@google.com, glommer@parallels.com, kamezawa.hiroyu@jp.fujitsu.com, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org, rientjes@google.com, cl@linux-foundation.org, akpm@linux-foundation.org

On Mon, 27 Feb 2012, Suleiman Souhlal wrote:
> The main difference with Glauber's patches is here: We try to
> track all the slab allocations, while Glauber only tracks ones
> that are explicitly marked.
> We feel that it's important to track everything, because there
> are a lot of different slab allocations that may use significant
> amounts of memory, that we may not know of ahead of time.
> This is also the main source of complexity in the patchset.

Well, what are the performance implications of your patches? Can we 
reasonably expect distributions to be able to enable this thing on 
generic kernels and leave the feature disabled by default? Can we 
accommodate your patches to support Glauber's use case?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
