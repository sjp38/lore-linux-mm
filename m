Date: Mon, 1 Aug 2005 13:26:19 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <20050801131240.4e8b1873.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0508011323330.3341@g5.osdl.org>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
 <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.61.0508012045050.5373@goblin.wat.veritas.com>
 <20050801131240.4e8b1873.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, nickpiggin@yahoo.com.au, holt@sgi.com, mingo@elte.hu, roland@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 1 Aug 2005, Andrew Morton wrote:
>
> We could just do:
> 
> static inline int handle_mm_fault(...)
> {
> 	int ret = __handle_mm_fault(...);
> 
> 	if (unlikely(ret == VM_FAULT_RACE))
> 		ret = VM_FAULT_MINOR;

The reason I really dislike this whole VM_FAULT_RACE thing is that there's 
literally just one user that cares, and that user is such a special case 
anyway that we're _much_  better off fixing it in that user instead.

The dirty bit thing is truly trivial, and is a generic VM feature. The
fact that s390 does strange things is immaterial: I bet that s390 can be
fixed much more easily than the suggested VM_FAULT_RACE patch, and quite
frankly, bringing it semantically closer to the rest of the architectures
is a _good_ thing regardless.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
