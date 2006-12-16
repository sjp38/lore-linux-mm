Date: Sat, 16 Dec 2006 21:23:46 +0000
From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: Recent mm changes leading to filesystem corruption?
Message-ID: <20061216212346.GA4426@unjust.cyrius.com>
References: <20061216155044.GA14681@deprecation.cyrius.com> <1166302516.10372.5.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1166302516.10372.5.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, debian-kernel@lists.debian.org, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <a.p.zijlstra@chello.nl> [2006-12-16 21:55]:
> What is not clear from all these reports is what architectures this is
> seen on. I suspect some of them are i686, which together with the
> explicit mention of ARM make it a cross platform issue.

Problems have been seen at least on x86, x86_64 and arm.
-- 
Martin Michlmayr
tbm@cyrius.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
