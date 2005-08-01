Message-ID: <42EDEAFE.1090600@yahoo.com.au>
Date: Mon, 01 Aug 2005 19:27:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
References: <20050801032258.A465C180EC0@magilla.sf.frob.com> <42EDDB82.1040900@yahoo.com.au> <20050801091956.GA3950@elte.hu>
In-Reply-To: <20050801091956.GA3950@elte.hu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:

>>Feedback please, anyone.
> 
> 
> it looks good to me, but wouldnt it be simpler (in terms of patch and 
> architecture impact) to always retry the follow_page() in 
> get_user_pages(), in case of a minor fault? The sequence of minor faults 

I believe this can break some things. Hugh posted an example
in his recent post to linux-mm (ptrace setting a breakpoint
in read-only text). I think?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
