Message-ID: <46E85825.4050505@google.com>
Date: Wed, 12 Sep 2007 14:20:37 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 4/5] Mem Policy:  cpuset-independent interleave policy
References: <20070830185053.22619.96398.sendpatchset@localhost> <20070830185122.22619.56636.sendpatchset@localhost>
In-Reply-To: <20070830185122.22619.56636.sendpatchset@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

the feature set I was interested in. One question regarding:

Lee Schermerhorn wrote:
> 
> However, this will involve testing possibly several words of
> bitmask in the allocation path.  Instead, I chose to encode the
> "context-dependent policy" indication in the upper bits of the
> policy member of the mempolicy structure.  This member must
> already be tested to determine the policy mode, so no extra
> memory references should be required.  However, for testing the
> policy--e.g., in the several switch() and if() statements--the
> context flag must be masked off using the policy_mode() inline
> function.  On the upside, this allows additional flags to be so
> encoded, should that become useful.

	Instead of creating MPOL_CONTEXT, did you consider instead creating a 
new MPOL for this, such as MPOL_INTERLEAVE_ALL? If the only intended 
user of the MPOL_CONTEXT "flag" is just MPOL_INTERLEAVE_ALL, it seems 
like you'll have simpler code this way.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
