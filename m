Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 329B26B0088
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 07:26:21 -0400 (EDT)
Received: by wguu7 with SMTP id u7so14891114wgu.3
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 04:26:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dw6si4113915wib.5.2015.06.19.04.26.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 04:26:19 -0700 (PDT)
Message-ID: <5583FC5D.6070201@suse.cz>
Date: Fri, 19 Jun 2015 13:26:21 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, thp: respect MPOL_PREFERRED policy with non-local
 node
References: <1434639273-9527-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1506181231011.3668@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1506181231011.3668@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>

On 18.6.2015 21:32, David Rientjes wrote:
> On Thu, 18 Jun 2015, Vlastimil Babka wrote:
> 
>> Fixes: 077fcf116c8c ("mm/thp: allocate transparent hugepages on local node")
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Good catch! 

Thanks!

> I think this is deserving of stable@vger.kernel.org # 4.0+

I thought it wouldn't qualify as critical bugfix, but I wouldn't mind.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
