Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 40F6F6B003B
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:32:16 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1080480pdb.27
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:32:15 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i5si2017569pdp.16.2014.08.29.12.32.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 12:32:15 -0700 (PDT)
Message-ID: <5400D535.9080002@oracle.com>
Date: Fri, 29 Aug 2014 15:32:05 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] Convert a few VM_BUG_ON callers to VM_BUG_ON_VMA
References: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com> <1409324059-28692-3-git-send-email-sasha.levin@oracle.com> <20140829191719.GC12774@nhori.bos.redhat.com>
In-Reply-To: <20140829191719.GC12774@nhori.bos.redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/29/2014 03:17 PM, Naoya Horiguchi wrote:
>> -	VM_BUG_ON(!PageLocked(page));
>> > +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> This is not the replacement with VM_BUG_ON_VMA(), but it's fine :)

Woops, I was on a spree and got this one as well.

Thanks for the review Naoya!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
