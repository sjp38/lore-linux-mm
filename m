Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFC16B00EC
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:08:31 -0500 (EST)
Message-ID: <4CE39B89.8010908@kernel.org>
Date: Wed, 17 Nov 2010 10:08:25 +0100
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [patch 2/3] mm: remove gfp mask from pcpu_get_vm_areas
References: <alpine.DEB.2.00.1011161935500.19230@chino.kir.corp.google.com> <alpine.DEB.2.00.1011161937380.19230@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1011161937380.19230@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/17/2010 04:41 AM, David Rientjes wrote:
> pcpu_get_vm_areas() only uses GFP_KERNEL allocations, so remove the gfp_t
> formal and use the mask internally.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Patch itself looks okay to me but why do you want to drop the
argument?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
