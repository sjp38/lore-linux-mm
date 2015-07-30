Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id F1C246B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 16:07:29 -0400 (EDT)
Received: by qkdg63 with SMTP id g63so22165280qkd.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:07:29 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id 131si2695494qhf.49.2015.07.30.13.07.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 13:07:29 -0700 (PDT)
Date: Thu, 30 Jul 2015 15:07:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 1/3] mm: rename alloc_pages_exact_node to
 __alloc_pages_node
In-Reply-To: <55BA822B.3020508@suse.cz>
Message-ID: <alpine.DEB.2.11.1507301506560.6410@east.gentwo.org>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.11.1507301255380.5521@east.gentwo.org> <55BA822B.3020508@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Michael Ellerman <mpe@ellerman.id.au>, Robin Holt <robinmholt@gmail.com>

On Thu, 30 Jul 2015, Vlastimil Babka wrote:

> > NAK. This is changing slob behavior. With no node specified it must use
> > alloc_pages because that obeys NUMA memory policies etc etc. It should not
> > force allocation from the current node like what is happening here after
> > the patch. See the code in slub.c that is similar.
>
> Doh, somehow I convinced myself that there's #else and alloc_pages() is only
> used for !CONFIG_NUMA so it doesn't matter. Here's a fixed version.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
