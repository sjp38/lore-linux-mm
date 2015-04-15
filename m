Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C42C86B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 08:53:08 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so51661845pdb.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 05:53:08 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id zb14si6912366pac.209.2015.04.15.05.53.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 05:53:07 -0700 (PDT)
Message-ID: <552E5F2B.7070604@oracle.com>
Date: Wed, 15 Apr 2015 08:52:59 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 00/11] mm: debug: formatting memory management structs
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com> <20150415084536.GA27510@node.dhcp.inet.fi>
In-Reply-To: <20150415084536.GA27510@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On 04/15/2015 04:45 AM, Kirill A. Shutemov wrote:
> On Tue, Apr 14, 2015 at 04:56:22PM -0400, Sasha Levin wrote:
>> > This patch series adds knowledge about various memory management structures
>> > to the standard print functions.
>> > 
>> > In essence, it allows us to easily print those structures:
>> > 
>> > 	printk("%pZp %pZm %pZv", page, mm, vma);
> Notably, you don't have \n in your format line. And it brings question how
> well dump_page() and friends fit printk-like interface. dump_page()
> produces multi-line print out.
> Is it something printk() users would expect?

Since were printing large amount of data out of multiple fields (rather than just
one potentially long field like "path"), the way I see it we could print it in one
line, and let it wrap.

While this is what printk users would most likely expect in theory, in practice it
might scroll off the screen, making us miss important output, it would also be awkward
making that long line part of anything else; what else would you add there?

While if we break it up into multiple lines, we keep it working the same way it worked
so far. Also, using any of those new printk format specifiers wouldn't be too common, so
we can hope that whoever uses them knows what he's doing and how the output will look
like.

Is there a usecase where we'd want to keep it as a single line?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
