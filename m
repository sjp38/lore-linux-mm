Date: Wed, 9 Nov 2005 16:56:33 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 4/4] Hugetlb: Copy on Write support
Message-ID: <20051110005633.GO29402@holomorphy.com>
References: <1131578925.28383.9.camel@localhost.localdomain> <1131579596.28383.25.camel@localhost.localdomain> <20051110001534.GN29402@holomorphy.com> <20051110004907.GA17840@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051110004907.GA17840@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Adam Litke <agl@us.ibm.com>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, rohit.seth@intel.com, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 09, 2005 at 04:15:34PM -0800, William Lee Irwin wrote:
>> Did you do the audit of pte protection bits I asked about? If not, I'll
>> dredge them up and check to make sure.

On Thu, Nov 10, 2005 at 11:49:07AM +1100, David Gibson wrote:
> I still don't know what you're talking about here - you never
> responded to my mail asking for clarification.  The hugepage code
> already relies on pte_mkwrite() and pte_wrprotect() working correctly,
> I don't see that COW makes any difference.

You appear to have a good idea of what's going on given that you've
reminded me of that reliance. It looks like I dropped that email packet
for some reason, sorry about that.

Acked-by: William Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
