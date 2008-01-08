Date: Tue, 8 Jan 2008 23:16:46 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/10] percpu: Per cpu code simplification V3
Message-ID: <20080108221646.GC21482@elte.hu>
References: <20080108021142.585467000@sgi.com> <20080108090702.GB27671@elte.hu> <Pine.LNX.4.64.0801081102450.2228@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801081102450.2228@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 8 Jan 2008, Ingo Molnar wrote:
> 
> > i had the patch below for v2, it's still needed (because i didnt 
> > apply the s390/etc. bits), right?
> 
> Well the patch really should go through mm because it is a change that 
> covers multiple arches. I think testing with this is fine. I think 
> Mike has diffed this against Linus tree so this works but will now 
> conflict with the modcopy patch already in mm.

well we cannot really ack it for x86 inclusion without having tested it 
through, so it will stay in x86.git for some time. That approach found a 
few problems with v1 already. In any case, v3 is looking pretty good so 
far - and it's cool stuff - i'm all for unifying/generalizing arch code.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
