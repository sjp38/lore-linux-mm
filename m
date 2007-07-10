Received: by wa-out-1112.google.com with SMTP id m33so1645532wag
        for <linux-mm@kvack.org>; Tue, 10 Jul 2007 02:31:41 -0700 (PDT)
Message-ID: <84144f020707100231p5013e1aer767562c26fc52eeb@mail.gmail.com>
Date: Tue, 10 Jul 2007 12:31:40 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 09/10] Remove the SLOB allocator for 2.6.23
In-Reply-To: <469342DC.8070007@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070708034952.022985379@sgi.com>
	 <20070708035018.074510057@sgi.com> <20070708075119.GA16631@elte.hu>
	 <20070708110224.9cd9df5b.akpm@linux-foundation.org>
	 <4691A415.6040208@yahoo.com.au>
	 <84144f020707090404l657a62c7x89d7d06b3dd6c34b@mail.gmail.com>
	 <Pine.LNX.4.64.0707090907010.13970@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0707101049230.23040@sbz-30.cs.Helsinki.FI>
	 <469342DC.8070007@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com, corey.d.gough@intel.com, Matt Mackall <mpm@selenic.com>, Denis Vlasenko <vda.linux@googlemail.com>, Erik Andersen <andersen@codepoet.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

Pekka J Enberg wrote:
> > That's 92 KB advantage for SLUB with debugging enabled and 240 KB when
> > debugging is disabled.

On 7/10/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Interesting. What kernel version are you using?

Linus' git head from yesterday so the results are likely to be
sensitive to workload and mine doesn't represent real embedded use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
