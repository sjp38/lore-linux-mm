Subject: o1-interactivity.patch (was Re: 2.5.74-mm1)
References: <20030703023714.55d13934.akpm@osdl.org>
From: Sean Neakums <sneakums@zork.net>
Date: Thu, 03 Jul 2003 14:15:51 +0100
In-Reply-To: <20030703023714.55d13934.akpm@osdl.org> (Andrew Morton's
 message of "Thu, 3 Jul 2003 02:37:14 -0700")
Message-ID: <6u65mjkayg.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> writes:

> . Included Con's CPU scheduler changes.  Feedback on the effectiveness of
>   this and the usual benchmarks would be interesting.

I find that this patch makes X really choppy when Mozilla Firebird is
loading a page (which it does through an ssh tunnel here).  Both the X
pointer and the spinner in the tab that is loading stop and start, for
up to a second at a time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
