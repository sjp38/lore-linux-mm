From: Andi Kleen <ak@suse.de>
Subject: Re: Benchmarks to exploit LRU deficiencies
Date: Tue, 11 Oct 2005 10:10:06 +0200
References: <20051010184636.GA15415@logos.cnet> <200510110241.42225.ak@suse.de> <20051010232104.GB4946@logos.cnet>
In-Reply-To: <20051010232104.GB4946@logos.cnet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510111010.06650.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, sjiang@lanl.gov, rni@andrew.cmu.edu, a.p.zijlstra@chello.nl, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tuesday 11 October 2005 01:21, Marcelo Tosatti wrote:

> You mean rsync kicks out your pagecache working set?

Yes.

> How come the machine is unusable?

Everything is very slow.

> How can the problem be reproduced? Run rsync is too vague I guess.

Is it? Just try it. 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
