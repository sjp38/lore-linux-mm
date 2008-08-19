Message-ID: <48AB2A01.2050500@cs.helsinki.fi>
Date: Tue, 19 Aug 2008 23:16:01 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with	_RET_IP_.
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro> <48AB0D69.4090703@linux-foundation.org> <20080819182423.GA5520@localhost> <48AB1769.3040703@linux-foundation.org> <48AB1A5B.3020305@cs.helsinki.fi> <48AB2A4A.7040103@linux-foundation.org>
In-Reply-To: <48AB2A4A.7040103@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Pekka Enberg wrote:
> 
>> This looks wrong. The '%pS' thingy has a special purpose:
>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7daf705f362e349983e92037a198b8821db198af
> 
> True. Just had 10 minutes to do the patch. Can someone stitch all of the good
> things from all three patches together?

I already did that:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=3c0a0d0e24234704387f6356ffc7b47758dc1e05

It's compiled-tested too. I had to do some changes to 
include/linux/slab.h as well.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
