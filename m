Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DDDC16B0108
	for <linux-mm@kvack.org>; Sun, 20 Sep 2009 06:12:10 -0400 (EDT)
Message-ID: <4AB5FFF8.7000602@cs.helsinki.fi>
Date: Sun, 20 Sep 2009 13:12:08 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie>	 <1253302451-27740-2-git-send-email-mel@csn.ul.ie> <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com> <4AB5FD4D.3070005@kernel.org>
In-Reply-To: <4AB5FD4D.3070005@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Tejun Heo wrote:
> Pekka Enberg wrote:
>> On Fri, Sep 18, 2009 at 10:34 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>>> SLQB used a seemingly nice hack to allocate per-node data for the statically
>>> initialised caches. Unfortunately, due to some unknown per-cpu
>>> optimisation, these regions are being reused by something else as the
>>> per-node data is getting randomly scrambled. This patch fixes the
>>> problem but it's not fully understood *why* it fixes the problem at the
>>> moment.
>> Ouch, that sounds bad. I guess it's architecture specific bug as x86
>> works ok? Lets CC Tejun.
> 
> Is the corruption being seen on ppc or s390?

On ppc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
