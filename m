Date: Fri, 5 Oct 2007 15:54:18 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] remove throttle_vm_writeout()
Message-ID: <20071005155418.5309e9c3@cuia.boston.redhat.com>
In-Reply-To: <1191569577.22357.22.camel@twins>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	<20071004145640.18ced770.akpm@linux-foundation.org>
	<E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
	<20071004160941.e0c0c7e5.akpm@linux-foundation.org>
	<1191569577.22357.22.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 05 Oct 2007 09:32:57 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> I think just adding nr_cpus * ratelimit_pages to the dirth_thresh in
> throttle_vm_writeout() will also solve the problem

Agreed, that should fix the main latency issues.
 
-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
