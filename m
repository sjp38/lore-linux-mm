Date: Wed, 2 Jan 2008 22:33:31 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 05/10] x86_64: Use generic percpu
Message-ID: <20080102213331.GA14664@elte.hu>
References: <20071228001046.854702000@sgi.com> <20071228001047.556634000@sgi.com> <200712281354.52453.ak@suse.de> <47757311.5050503@sgi.com> <20071230141829.GA28415@elte.hu> <477916ED.8010602@sgi.com> <47792295.8070001@sgi.com> <20080101191758.GA14045@elte.hu> <Pine.LNX.4.64.0801021302530.22538@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801021302530.22538@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mike Travis <travis@sgi.com>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 1 Jan 2008, Ingo Molnar wrote:
> 
> > FYI, i tried your patchset on 2.6.24-rc6+x86.git, and randconfig testing 
> > found a faulty 32-bit config below - the bootup would spontaneously 
> > reboot shortly after hitting user-space. (which suggests a triple fault) 
> > No log messages on the serial console.
> 
> The triple fault does not occur without the patchset?

correct.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
