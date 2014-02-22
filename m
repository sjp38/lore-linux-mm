Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id AB4E76B00F4
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 20:10:44 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id k15so4220180qaq.33
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 17:10:44 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a51si5587921qge.60.2014.02.21.17.10.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 17:10:44 -0800 (PST)
Message-ID: <5307F90C.9060602@oracle.com>
Date: Fri, 21 Feb 2014 20:10:36 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm:  kernel BUG at mm/huge_memory.c:1371!
References: <5307D74C.5070002@oracle.com> <20140221235145.GA18046@node.dhcp.inet.fi>
In-Reply-To: <20140221235145.GA18046@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 02/21/2014 06:51 PM, Kirill A. Shutemov wrote:
> On Fri, Feb 21, 2014 at 05:46:36PM -0500, Sasha Levin wrote:
>> >Hi all,
>> >
>> >While fuzzing with trinity inside a KVM tools guest running latest -next
>> >kernel I've stumbled on the following (now with pretty line numbers!) spew:
>> >
>> >[  746.125099] kernel BUG at mm/huge_memory.c:1371!
> It "VM_BUG_ON_PAGE(!PageHead(page), page);", correct?
> I don't see dump_page() output.

Right. However, I'm not seeing the dump_page() output in the log.

I see that dump_page() has been modified not long ago, I'm looking into it.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
