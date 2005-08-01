Date: Mon, 1 Aug 2005 13:12:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
Message-Id: <20050801131240.4e8b1873.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.61.0508012045050.5373@goblin.wat.veritas.com>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
	<42EDDB82.1040900@yahoo.com.au>
	<Pine.LNX.4.61.0508012045050.5373@goblin.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: nickpiggin@yahoo.com.au, holt@sgi.com, torvalds@osdl.org, mingo@elte.hu, roland@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> There are currently 21 architectures,
> but so far your patch only updates 14 of them?

We could just do:

static inline int handle_mm_fault(...)
{
	int ret = __handle_mm_fault(...);

	if (unlikely(ret == VM_FAULT_RACE))
		ret = VM_FAULT_MINOR;
	return ret;
}

because VM_FAULT_RACE is some internal private thing.

It does add another test-n-branch to the pagefault path though.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
