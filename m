Subject: Re: [patch] real-time enhanced page allocator and throttling
From: Robert Love <rml@tech9.net>
In-Reply-To: <20030805174536.6cb5fbf0.akpm@osdl.org>
References: <1060121638.4494.111.camel@localhost>
	 <20030805170954.59385c78.akpm@osdl.org>
	 <1060130368.4494.166.camel@localhost>
	 <20030805174536.6cb5fbf0.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1060142290.4494.197.camel@localhost>
Mime-Version: 1.0
Date: 05 Aug 2003 20:58:11 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, Valdis.Kletnieks@vt.edu, piggin@cyberone.com.au, kernel@kolivas.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2003-08-05 at 17:45, Andrew Morton wrote:

> It's testing time.

Just via some instrumenting, I can see that a real-time task never
begins throttling and this translates to a ~1ms reduction in worst case
allocation on a fast machine latency under extreme page dirtying and
writeback (basically, I cannot reproduce any variation in page
allocation, now, for a real-time test app). So it works.

But I do not have any real world test to confirm a benefit, which is
what matters. Have you poked and prodded?

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
