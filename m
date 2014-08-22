Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 280646B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 16:32:25 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so16995850pab.33
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 13:32:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bf4si42368558pdb.231.2014.08.22.13.32.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Aug 2014 13:32:24 -0700 (PDT)
Date: Fri, 22 Aug 2014 13:32:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/4] Improve slab consumption with memoryless nodes
Message-Id: <20140822133222.d3079dcd85ef1f5d1b4093ed@linux-foundation.org>
In-Reply-To: <20140822011011.GF13999@linux.vnet.ibm.com>
References: <20140814001301.GI11121@linux.vnet.ibm.com>
	<20140822011011.GF13999@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On Thu, 21 Aug 2014 18:10:11 -0700 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:

> I know kernel summit is going on, so I'll be patient, but was just
> curious if anyone had any further comments other than Christoph's on the
> naming.

Nope.  Please make a decision on the naming, refresh, retest and resend
and I'll get the patches queued up for review and testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
