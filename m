Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7BEC66B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 06:59:47 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so26527315lbb.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 03:59:46 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id j5si12134335laf.127.2015.05.13.03.59.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 03:59:45 -0700 (PDT)
Message-ID: <55532E9D.1040702@yandex-team.ru>
Date: Wed, 13 May 2015 13:59:41 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] pagemap: add mmap-exclusive bit for marking pages
 mapped only here
References: <20150512090156.24768.2521.stgit@buzz> <20150512094303.24768.10282.stgit@buzz> <20150512104055.GB18365@node.dhcp.inet.fi>
In-Reply-To: <20150512104055.GB18365@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mark Williamson <mwilliamson@undo-software.com>, Pavel Emelyanov <xemul@parallels.com>, linux-api@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

On 12.05.2015 13:40, Kirill A. Shutemov wrote:
> On Tue, May 12, 2015 at 12:43:03PM +0300, Konstantin Khlebnikov wrote:
>> This patch sets bit 56 in pagemap if this page is mapped only once.
>> It allows to detect exclusively used pages without exposing PFN:
>>
>> present file exclusive state
>> 0       0    0         non-present
>> 1       1    0         file page mapped somewhere else
>> 1       1    1         file page mapped only here
>> 1       0    0         anon non-CoWed page (shared with parent/child)
>> 1       0    1         anon CoWed page (or never forked)
>
> Probably, worth noting that file-private pages are anon in this context.
>

You mean there's another kind of CoW pages? Yep, but from the kernel
point of view these pages are the same. Anyway Userspace could look
into /proc/*/maps and see is there any file beyond anon vma.

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
