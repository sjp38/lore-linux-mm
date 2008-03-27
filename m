Date: Thu, 27 Mar 2008 11:44:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: What if a TLB flush needed to sleep?
In-Reply-To: <1206624052.8514.570.camel@twins>
Message-ID: <Pine.LNX.4.64.0803271143540.7531@schroedinger.engr.sgi.com>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com>
  <Pine.LNX.4.64.0803261222090.31000@schroedinger.engr.sgi.com>
 <alpine.LFD.1.00.0803262121440.3781@apollo.tec.linutronix.de>
 <Pine.LNX.4.64.0803261817110.1115@schroedinger.engr.sgi.com>
 <1206624052.8514.570.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "Luck, Tony" <tony.luck@intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Mar 2008, Peter Zijlstra wrote:

> confusion between semaphores and rwsems

rwsem is not a semaphore despite its name? What do you want to call it 
then?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
