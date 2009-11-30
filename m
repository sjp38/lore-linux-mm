Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5FEB2600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 11:23:57 -0500 (EST)
Date: Mon, 30 Nov 2009 10:23:37 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2 10/12] Maintain preemptability count even for
 !CONFIG_PREEMPT kernels
In-Reply-To: <1259579114.20516.136.camel@laptop>
Message-ID: <alpine.DEB.2.00.0911301021490.14098@router.home>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>  <1258985167-29178-11-git-send-email-gleb@redhat.com>  <1258990455.4531.594.camel@laptop> <20091123155851.GU2999@redhat.com>  <alpine.DEB.2.00.0911231128190.785@router.home>  <20091124071250.GC2999@redhat.com>
  <alpine.DEB.2.00.0911240906360.14045@router.home>  <20091130105612.GF30150@redhat.com>  <20091130105812.GG30150@redhat.com>  <1259578793.20516.130.camel@laptop> <1259579114.20516.136.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Ok so there is some variance in tests as usual due to cacheline placement.
But it seems that overall we are looking at a 1-2% regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
