Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 900996B01B8
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:30:51 -0400 (EDT)
Message-ID: <4C2A118C.2030206@kernel.org>
Date: Tue, 29 Jun 2010 17:30:20 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
References: <20100625212026.810557229@quilx.com> <20100625212106.384650677@quilx.com> <4C25B610.1050305@kernel.org> <alpine.DEB.2.00.1006291014540.16135@router.home>
In-Reply-To: <alpine.DEB.2.00.1006291014540.16135@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On 06/29/2010 05:15 PM, Christoph Lameter wrote:
> On Sat, 26 Jun 2010, Tejun Heo wrote:
> 
>> Christoph, how do you wanna route these patches?  I already have the
>> other two patches in the percpu tree, I can push this there too, which
>> then you can pull into the allocator tree.
> 
> Please push via your trees. Lets keep stuff subsystem specific if
> possible.

Sure, please feel free to pull from the following tree.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git for-next

I haven't committed the gfp_allowed_mask patch yet.  I'll commit it
once it gets resolved.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
