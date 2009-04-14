Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9FA615F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 10:41:44 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
Date: Wed, 15 Apr 2009 00:42:14 +1000
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <200904150026.36142.nickpiggin@yahoo.com.au> <20090414143252.GE28265@random.random>
In-Reply-To: <20090414143252.GE28265@random.random>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904150042.15653.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 15 April 2009 00:32:52 Andrea Arcangeli wrote:
> On Wed, Apr 15, 2009 at 12:26:34AM +1000, Nick Piggin wrote:
> > Andrea: I didn't veto that set_bit change of yours as such. I just
> 
> I know you didn't ;)
> 
> > noted there could be more atomic operations. Actually I would
> > welcome more comparison between our two approaches, but they seem
> 
> Agree about the welcome of comparison, it'd be nice to measure it the
> enterprise workloads that showed the gup_fast gain in the first place.

I think we should be able to ask IBM to run some tests, provided
they still have machines available to do so. Although I don't want
to waste their time so we need to have something that has got past
initial code review and has a chance of being merged.

If we get that far, then I can ask them to run tests definitely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
