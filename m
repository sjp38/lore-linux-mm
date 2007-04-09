Date: Mon, 9 Apr 2007 09:40:29 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 1/4] x86_64: (SPARSE_VIRTUAL doubles sparsemem speed)
Message-ID: <20070409164029.GT2986@holomorphy.com>
References: <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com> <200704011246.52238.ak@suse.de> <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com> <1175544797.22373.62.camel@localhost.localdomain> <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com> <461169CF.6060806@google.com> <Pine.LNX.4.64.0704021345110.1224@schroedinger.engr.sgi.com> <4614E293.3010908@shadowen.org> <Pine.LNX.4.64.0704051119400.9800@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0704071455060.31468@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704071455060.31468@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Martin Bligh <mbligh@google.com>, Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 07, 2007 at 03:06:13PM -0700, Christoph Lameter wrote:
> +/*
> + * Performance Counters and Measurement macros
> + * (C) 2005 Silicon Graphics Incorporated
> + * by Christoph Lameter <clameter@sgi.com>, April 2005
> + *
> + * Counters are calculated using the cycle counter. If a process
> + * is migrated to another cpu during the measurement then the measurement
> + * is invalid.
> + *
> + * We cannot disable preemption during measurement since that may interfere
> + * with other things in the kernel and limit the usefulness of the counters.
> + */

Whatever's going on with the rest of this, I really like this
instrumentation patch. It may be worthwhile to allow pc_start() to be
overridden so things like performance counter MSR's are usable, but
the framework looks very useful.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
