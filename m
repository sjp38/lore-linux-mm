Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6F76B0031
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 15:06:27 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id k19so21853942igc.1
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 12:06:27 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id yw9si21594280icb.51.2013.12.23.12.06.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Dec 2013 12:06:26 -0800 (PST)
Message-ID: <52B897BC.4030901@oracle.com>
Date: Mon, 23 Dec 2013 15:06:20 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1440!
References: <52B88F6E.8070909@oracle.com> <20131223200255.GA18521@node.dhcp.inet.fi>
In-Reply-To: <20131223200255.GA18521@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 12/23/2013 03:02 PM, Kirill A. Shutemov wrote:
>> [  265.474585] kernel BUG at mm/huge_memory.c:1440!
> Could you dump_page() on the bug?

Added it in. It doesn't reproduce too easily so it might take a bit.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
