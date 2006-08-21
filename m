Date: Mon, 21 Aug 2006 15:38:44 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Message-ID: <20060821133843.GE4290@suse.de>
References: <20060813185309.928472f9.akpm@osdl.org> <1155530453.5696.98.camel@twins> <20060813215853.0ed0e973.akpm@osdl.org> <44E3E964.8010602@google.com> <20060816225726.3622cab1.akpm@osdl.org> <44E5015D.80606@google.com> <20060817230556.7d16498e.akpm@osdl.org> <44E62F7F.7010901@google.com> <20060818153455.2a3f2bcb.akpm@osdl.org> <44E650C1.80608@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44E650C1.80608@google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@google.com>
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, riel@redhat.com, tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 18 2006, Daniel Phillips wrote:
> nearly the same kind of function, and suffering very nearly the same kind
> of problems we had in the block layer before mingo's mempool machinery
> arrived?

Correction, the block layer wasn't buggy (eg deadlock prone) before
mempool, mempool was merely an abstraction that allowed to move this
code out of the bio.c file since it was apparent that it had other
possible users as well.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
