Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7D66B0032
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 18:05:52 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id tp5so14722020ieb.12
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 15:05:52 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id ky10si17486657icc.31.2014.12.03.15.05.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 15:05:50 -0800 (PST)
Message-ID: <1417640517.4741.14.camel@kernel.crashing.org>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to
 p[te|md]_protnone_numa
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 04 Dec 2014 08:01:57 +1100
In-Reply-To: <20141203155242.GE6043@suse.de>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de>
	 <1416578268-19597-4-git-send-email-mgorman@suse.de>
	 <1417473762.7182.8.camel@kernel.crashing.org>
	 <87k32ah5q3.fsf@linux.vnet.ibm.com>
	 <1417551115.27448.7.camel@kernel.crashing.org>
	 <87lhmobvuu.fsf@linux.vnet.ibm.com> <20141203155242.GE6043@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 2014-12-03 at 15:52 +0000, Mel Gorman wrote:
> 
> It's implied but can I assume it passed? If so, Ben and Paul, can I
> consider the series to be acked by you other than the minor comment
> updates?

Yes. Assuming it passed :-)

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
