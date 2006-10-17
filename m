Date: Mon, 16 Oct 2006 23:50:12 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Use min of two prio settings in calculating distress
 for reclaim
Message-Id: <20061016235012.aefd6c73.akpm@osdl.org>
In-Reply-To: <45347951.3050907@yahoo.com.au>
References: <4534323F.5010103@google.com>
	<45347951.3050907@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Martin Bligh <mbligh@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Oct 2006 16:33:53 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> And what have you done to akpm? ;)

I'm sulking.  Would prefer to bitbucket the whole ->prev_priority thing
and do something better, but I haven't got around to thinking about it yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
