Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E73A86B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 16:01:09 -0500 (EST)
Subject: Re: [MM] Make mm counters per cpu instead of atomic
From: Andi Kleen <andi@firstfloor.org>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
Date: Wed, 04 Nov 2009 22:01:05 +0100
In-Reply-To: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1> (Christoph Lameter's message of "Wed, 4 Nov 2009 14:14:41 -0500 (EST)")
Message-ID: <87r5se80oe.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux-foundation.org> writes:
>
> One price to pay for these improvements is the need to scan over all percpu
> counters when the actual count values are needed.

Do you have numbers how costly alloc_percpu() is? I wonder what this
does to fork() overhead.

-Andi
 

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
