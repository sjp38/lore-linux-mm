Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 450F26B0062
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 12:30:26 -0500 (EST)
Date: Mon, 23 Nov 2009 11:30:02 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2 10/12] Maintain preemptability count even for
 !CONFIG_PREEMPT kernels
In-Reply-To: <20091123155851.GU2999@redhat.com>
Message-ID: <alpine.DEB.2.00.0911231128190.785@router.home>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com> <1258985167-29178-11-git-send-email-gleb@redhat.com> <1258990455.4531.594.camel@laptop> <20091123155851.GU2999@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

This adds significant overhead for the !PREEMPT case adding lots of code
in critical paths all over the place.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
