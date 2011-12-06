Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 74CC36B005A
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 05:26:17 -0500 (EST)
Date: Tue, 6 Dec 2011 11:26:23 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] mm,x86: initialize high mem before free_all_bootmem()
Message-ID: <20111206102622.GC3105@redhat.com>
References: <1322582711-14571-1-git-send-email-sgruszka@redhat.com>
 <20111205110656.GA22259@elte.hu>
 <20111205150019.GA5434@redhat.com>
 <20111205155434.GD30287@elte.hu>
 <20111206075530.GA3105@redhat.com>
 <20111206080833.GB3105@redhat.com>
 <20111206082555.GA28314@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111206082555.GA28314@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Dec 06, 2011 at 09:25:55AM +0100, Ingo Molnar wrote:
> The thing is, the pagealloc bug you fixed basically kept 
> pagealloc debugging essentially disabled for a really long time, 
> correct?
Yes, it worked only in special cases.
 
> So i'd expect there to be quite a few latent problems - 
> i'll give it some more testing before pushing out the result.
Ehh, I expect them too, but fortunately only with CONFIG_DEBUG_PAGEALLOC,
non-debug kernel are not affected.

Thanks
Stanislaw 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
