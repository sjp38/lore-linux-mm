Date: Tue, 21 Mar 2000 16:08:28 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Extensions to mincore
Message-ID: <20000321160828.C8204@redhat.com>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org> <20000321024731.C4271@pcep-jamie.cern.ch> <m1puso1ydn.fsf@flinx.hidden> <20000321113448.A6991@dukat.scot.redhat.com> <20000321161507.D5291@pcep-jamie.cern.ch> <20000321154117.A8113@dukat.scot.redhat.com> <20000321165532.A5461@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000321165532.A5461@pcep-jamie.cern.ch>; from jamie.lokier@cern.ch on Tue, Mar 21, 2000 at 04:55:32PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Mar 21, 2000 at 04:55:32PM +0100, Jamie Lokier wrote:
> 
> Didn't you read a few paragraphs down, where I explain how to implement
> this?  You've got struct page.  It is enough for private mappings, and
> we don't need this feature for shared mappings.

Umm, yes, but just saying "we'll solve synchronisation problems by 
stopping all the other threads" hardly seems like a "solution" to me:
more of a workaround of the problem!  mprotect() does work correctly
without stopping other threads.

> It would be enough the say "the mincore accessed/dirty bits are not
> guaranteed to be accurate if pages are accessed by concurrent threads
> during the mincore call".

Exactly why you need mprotect, which _does_ make the necessary 
guarantees.

Oh, and suggesting that we can obtain the dirty bit by assuming all
mappings are private doesn't work either.  Private mappings *need* a 
per-pte (NOT per-page, but per-pte) dirty bit to distinguish between 
pages shared with the underlying mapped object, and pages which have
been modified by the local process.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
