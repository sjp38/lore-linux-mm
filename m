Date: Wed, 26 Mar 2008 18:19:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: What if a TLB flush needed to sleep?
In-Reply-To: <alpine.LFD.1.00.0803262121440.3781@apollo.tec.linutronix.de>
Message-ID: <Pine.LNX.4.64.0803261817110.1115@schroedinger.engr.sgi.com>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com>
 <Pine.LNX.4.64.0803261222090.31000@schroedinger.engr.sgi.com>
 <alpine.LFD.1.00.0803262121440.3781@apollo.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Mar 2008, Thomas Gleixner wrote:

> Please use a mutex, not a semaphore. semaphores should only be used
> when you need a counting sempahore.

Seems that mutexes are mainly useful for 2 processor systems since they 
do not allow concurrent read sections. We want multiple processors able 
to reclaim pages within the same vma or file concurrently. This means 
processors need to be able to concurrently walk potentially long lists of 
vmas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
