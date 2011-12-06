Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 0D0A26B004F
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 03:27:36 -0500 (EST)
Date: Tue, 6 Dec 2011 09:25:55 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm,x86: initialize high mem before free_all_bootmem()
Message-ID: <20111206082555.GA28314@elte.hu>
References: <1322582711-14571-1-git-send-email-sgruszka@redhat.com>
 <20111205110656.GA22259@elte.hu>
 <20111205150019.GA5434@redhat.com>
 <20111205155434.GD30287@elte.hu>
 <20111206075530.GA3105@redhat.com>
 <20111206080833.GB3105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111206080833.GB3105@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>


* Stanislaw Gruszka <sgruszka@redhat.com> wrote:

> Patch fixes boot crash with my previous patch "mm,x86: remove
> debug_pagealloc_enabled" applied:

Great, thanks - i've started testing of your pagealloc 
restoration patch again.

> Would be good to apply this patch before "mm,x86: remove 
> debug_pagealloc_enabled" to prevent problem be possibly 
> observable during bisection.

Yep, applied them in that order.

The thing is, the pagealloc bug you fixed basically kept 
pagealloc debugging essentially disabled for a really long time, 
correct? So i'd expect there to be quite a few latent problems - 
i'll give it some more testing before pushing out the result.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
