Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id CB0356B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 09:04:27 -0400 (EDT)
Received: by weop45 with SMTP id p45so56718711weo.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 06:04:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex13si2923436wid.100.2015.03.19.06.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 06:04:26 -0700 (PDT)
Message-ID: <550AC958.9010502@suse.cz>
Date: Thu, 19 Mar 2015 14:04:24 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: protect suid binaries against rowhammer with
 copy-on-read mappings
References: <20150318083040.7838.76933.stgit@zurg> <20150318095702.GA2479@node.dhcp.inet.fi> <5509644C.40502@yandex-team.ru>
In-Reply-To: <5509644C.40502@yandex-team.ru>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On 03/18/2015 12:41 PM, Konstantin Khlebnikov wrote:
> On 18.03.2015 12:57, Kirill A. Shutemov wrote:
>>
>> I don't think it worth it. The only right way to fix the problem is ECC
>> memory.
>>
> 
> ECC seems good protection until somebody figure out how to break it too.

I doubt that kind of attitude can get us very far. If we can't trust the
hardware, we lose sooner or later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
