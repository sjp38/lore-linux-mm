Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id A2F846B006C
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 15:42:23 -0400 (EDT)
Date: Thu, 16 Aug 2012 21:42:10 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v3 6/7] mm: make clear_huge_page cache clear only around
 the fault address
Message-ID: <20120816194210.GR11188@redhat.com>
References: <1345130154-9602-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1345130154-9602-7-git-send-email-kirill.shutemov@linux.intel.com>
 <20120816161647.GM11188@redhat.com>
 <20120816164356.GA30106@shutemov.name>
 <20120816182944.GN11188@redhat.com>
 <20120816183725.GA30284@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120816183725.GA30284@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Thu, Aug 16, 2012 at 09:37:25PM +0300, Kirill A. Shutemov wrote:
> On Thu, Aug 16, 2012 at 08:29:44PM +0200, Andrea Arcangeli wrote:
> > On Thu, Aug 16, 2012 at 07:43:56PM +0300, Kirill A. Shutemov wrote:
> > > Hm.. I think with static_key we can avoid cache overhead here. I'll try.
> > 
> > Could you elaborate on the static_key? Is it some sort of self
> > modifying code?
> 
> Runtime code patching. See Documentation/static-keys.txt. We can patch it
> on sysctl.

I guessed it had to be patching the code, thanks for the
pointer. It looks a perfect fit for this one agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
