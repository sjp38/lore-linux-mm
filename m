Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id DF7D86B0035
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 08:32:39 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so9839032pdi.34
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 05:32:39 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bx4si3388013pdb.99.2014.07.28.05.32.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 05:32:39 -0700 (PDT)
Message-ID: <53D642D3.8020407@oracle.com>
Date: Mon, 28 Jul 2014 08:32:19 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't allow fault_around_bytes to be 0
References: <53D07E96.5000006@oracle.com> <1406533400-6361-1-git-send-email-a.ryabinin@samsung.com> <20140728093611.GA3975@node.dhcp.inet.fi> <53D62599.6000605@samsung.com>
In-Reply-To: <53D62599.6000605@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Hugh Dickins <hughd@google.com>

On 07/28/2014 06:27 AM, Andrey Ryabinin wrote:
>> Although, I'm not convinced that it caused the issue. Sasha, did you touch the
>> > debugfs handle?
>> > 
> I suppose trinity could change it, no? I've got the very same spew after setting fault_around_bytes to 0.

Not on purpose, but as Andrey said - it's very possible that trinity did.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
