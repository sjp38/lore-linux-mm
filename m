From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 00/10] x86: Reduce memory and intra-node effects with large count NR_CPUs
Date: Mon, 14 Jan 2008 11:04:18 +0100
References: <20080113183453.973425000@sgi.com> <20080114081418.GB18296@elte.hu>
In-Reply-To: <20080114081418.GB18296@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801141104.18789.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> i.e. we've got ~22K bloat per CPU - which is not bad, but because it's a 
> static component, it hurts smaller boxes. For distributors to enable 
> CONFIG_NR_CPU=1024 by default i guess that bloat has to drop below 1-2K 
> per CPU :-/ [that would still mean 1-2MB total bloat but that's much 
> more acceptable than 23MB]

Even 1-2MB overhead would be too much for distributors I think. Ideally
there must be near zero overhead for possible CPUs (and I see no principle
reason why this is not possible) Worst case a low few hundred KBs, but even
that would be much.

There are the cpusets which get passed around, but these are only one bit per 
possible CPU.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
