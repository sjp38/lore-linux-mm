Date: Wed, 2 Jan 2008 12:59:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 05/10] x86_64: Use generic percpu
In-Reply-To: <20071230141829.GA28415@elte.hu>
Message-ID: <Pine.LNX.4.64.0801021259040.22538@schroedinger.engr.sgi.com>
References: <20071228001046.854702000@sgi.com> <20071228001047.556634000@sgi.com>
 <200712281354.52453.ak@suse.de> <47757311.5050503@sgi.com>
 <20071230141829.GA28415@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Mike Travis <travis@sgi.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Sun, 30 Dec 2007, Ingo Molnar wrote:

> to get more test feedback: what would be the best way to get this tested 
> in x86.git in a standalone way? Can i just pick up these 10 patches and 
> remove all the non-x86 arch changes, and expect it to work - or are the 
> other percpu preparatory/cleanup patches in -mm needed too?

This is all you need. We intentionally did not include the other patches 
that go further.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
