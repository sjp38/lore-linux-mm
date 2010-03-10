Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 96E1B6B0093
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 04:07:07 -0500 (EST)
Message-ID: <4B976108.1010404@kernel.org>
Date: Wed, 10 Mar 2010 18:06:16 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 1/8] numa: prep:  move generic percpu interface definitions
 to percpu-defs.h
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>	 <20100304170702.10606.85808.sendpatchset@localhost.localdomain>	 <4B960AD0.8010709@kernel.org> <1268144009.27921.9.camel@useless.americas.hpqcorp.net>
In-Reply-To: <1268144009.27921.9.camel@useless.americas.hpqcorp.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Hello,

On 03/09/2010 11:13 PM, Lee Schermerhorn wrote:
>> Hmmm... I think uninlining !SMP case would be much cleaner.  Sorry
>> that you had to do it twice.  I'll break the dependency in the percpu
>> devel branch and let you know.
> 
> OK, I'll do that for V4.  It'll be one big ugly patch because of all the
> dependencies.  But, it's really just a mechanical change.

Just in case it wasn't clear.  I'm giving it a shot right now.  I
don't think it will be too ugly and it's something which should be
done whether ugly or not.  I'll let you know how it turns out.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
