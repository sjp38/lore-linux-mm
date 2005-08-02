Message-ID: <42EEBAE1.7050002@yahoo.com.au>
Date: Tue, 02 Aug 2005 10:14:25 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
References: <20050801032258.A465C180EC0@magilla.sf.frob.com> <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:

>
>On Mon, 1 Aug 2005, Nick Piggin wrote:
>
>>Not sure if this should be fixed for 2.6.13. It can result in
>>pagecache corruption: so I guess that answers my own question.
>>
>
>Hell no.
>
>This patch is clearly untested and must _not_ be applied:
>
>

Yes, I meant that the problem should be fixed, not that the
patch should be applied straight away.

I wanted to get discussion going ASAP. Looks like it worked :)
I'll catch up on it now.


Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
