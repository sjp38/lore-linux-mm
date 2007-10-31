Received: by an-out-0708.google.com with SMTP id d30so14076and
        for <linux-mm@kvack.org>; Wed, 31 Oct 2007 06:44:31 -0700 (PDT)
Message-ID: <472886B2.1060207@gmail.com>
Date: Wed, 31 Oct 2007 09:44:18 -0400
MIME-Version: 1.0
Subject: Re: [PATCH 00/33] Swap over NFS -v14
References: <20071030160401.296770000@chello.nl>	 <200710311426.33223.nickpiggin@yahoo.com.au>	 <1193830033.27652.159.camel@twins>  <47287220.8050804@garzik.org> <1193835413.27652.205.camel@twins>
In-Reply-To: <1193835413.27652.205.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
From: Gregory Haskins <gregory.haskins.ml@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jeff Garzik <jeff@garzik.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

> 
> But please, people who want this (I'm sure some of you are reading) do
> speak up. I'm just the motivated corporate drone implementing the
> feature :-)

FWIW, I could have used a "swap to network technology X" like system at
my last job.  We were building a large networking switch with blades,
and the IO cards didn't have anywhere near the resources that the
control modules had (no persistent storage, small ram, etc).  We were
already doing userspace coredumps over NFS to the control cards.  It
would have been nice to swap as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
