Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 187385F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:01:10 -0400 (EDT)
Date: Mon, 1 Jun 2009 23:41:25 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090601214125.GX1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601140553.GA1979@localhost> <Pine.LNX.4.64.0906012138170.27344@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906012138170.27344@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Maybe we should start out, as you have, with most of the hwpoison
> code located in one file (rather like with migrate.c?); but hope
> to refactor things and distribute it over time.

That's the plan.

> 
> How seriously does the hwpoison work interfere with the assumptions
> in other sourcefiles?  If it's playing tricks liable to confuse

I hope only minimally. It can come in at any time (that's the partly
tricky part), but in general it tries to be very conservative and
non intrusive and just calls code used elsewhere.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
