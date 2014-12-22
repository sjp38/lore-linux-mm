Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3107F6B006C
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 15:38:39 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id c41so2624195yho.17
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 12:38:38 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l6si9071692ykc.15.2014.12.22.12.38.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 12:38:38 -0800 (PST)
Message-ID: <54988142.40207@oracle.com>
Date: Mon, 22 Dec 2014 15:38:26 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: NULL ptr deref in unlink_file_vma
References: <549832E2.8060609@oracle.com>	 <20141222180102.GA8072@node.dhcp.inet.fi>	 <20141222180420.GA20261@node.dhcp.inet.fi> <1419275072.8812.1.camel@stgolabs.net>
In-Reply-To: <1419275072.8812.1.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>

On 12/22/2014 02:04 PM, Davidlohr Bueso wrote:
> Sasha, does this still occur if you revert c8475d144abb?

On 12/22/2014 02:14 PM, Kirill A. Shutemov wrote:
> Sasha could you check if you hit untrack_pfn()?

I'm afraid I only hit this issue once, unlike the other once which
was bisected down.

I'm trying to play with it a bit to see if I can "help" it reproduce,
but no luck so far.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
