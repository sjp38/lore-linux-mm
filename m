Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED9A6B0070
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 21:02:11 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id h136so22286438oig.9
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 18:02:11 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id sn7si3062266oeb.94.2015.01.28.18.02.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 18:02:10 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YGeQs-002oy6-2e
	for linux-mm@kvack.org; Thu, 29 Jan 2015 02:02:10 +0000
Message-ID: <54C9949C.9000703@roeck-us.net>
Date: Wed, 28 Jan 2015 18:02:04 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: split up mm_struct to separate header file
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com> <1422451064-109023-3-git-send-email-kirill.shutemov@linux.intel.com> <20150129003028.GA17519@node.dhcp.inet.fi>
In-Reply-To: <20150129003028.GA17519@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/28/2015 04:30 PM, Kirill A. Shutemov wrote:
> On Wed, Jan 28, 2015 at 03:17:42PM +0200, Kirill A. Shutemov wrote:
>> We want to use __PAGETABLE_PMD_FOLDED in mm_struct to drop nr_pmds if
>> pmd is folded. __PAGETABLE_PMD_FOLDED is defined in <asm/pgtable.h>, but
>> <asm/pgtable.h> itself wants <linux/mm_types.h> for struct page
>> definition.
>>
>> This patch move mm_struct definition into separate header file in order
>> to fix circular header dependencies.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>
> Guenter, below is update for the patch. It doesn't fix all the issues, but
> you should see an improvement. I'll continue with this tomorrow.
>
I'll give it a try.

> BTW, any idea where I can get hexagon cross compiler?
>

http://www.mentor.com/embedded-software/sourcery-tools/sourcery-codebench/editions/lite-edition/

It is 32 bit, so you'll have to install some 32 bit libraries.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
