Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DBC9F6B006A
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 02:13:25 -0500 (EST)
Date: Tue, 24 Nov 2009 09:12:50 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v2 10/12] Maintain preemptability count even for
 !CONFIG_PREEMPT kernels
Message-ID: <20091124071250.GC2999@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
 <1258985167-29178-11-git-send-email-gleb@redhat.com>
 <1258990455.4531.594.camel@laptop>
 <20091123155851.GU2999@redhat.com>
 <alpine.DEB.2.00.0911231128190.785@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0911231128190.785@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, Nov 23, 2009 at 11:30:02AM -0600, Christoph Lameter wrote:
> This adds significant overhead for the !PREEMPT case adding lots of code
> in critical paths all over the place.
> 
> 
I want to measure it. Can you suggest benchmarks to try?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
