Subject: Re: madvise(2) MADV_SEQUENTIAL behavior
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <487F89AE.9070007@redhat.com>
References: <1216163022.3443.156.camel@zenigma>
	 <487E628A.3050207@redhat.com>	<1216252910.3443.247.camel@zenigma>
	 <200807171614.29594.nickpiggin@yahoo.com.au>
	 <20080717102148.6bc52e94@cuia.bos.redhat.com> <487F89AE.9070007@redhat.com>
Content-Type: text/plain
Date: Thu, 17 Jul 2008 20:09:31 +0200
Message-Id: <1216318171.5232.98.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Snook <csnook@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Eric Rannaud <eric.rannaud@gmail.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Sorry can't resist...

On Thu, 2008-07-17 at 14:04 -0400, Chris Snook wrote:

> 1) start up a memory-hogging Java app

Is there any other kind? :-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
