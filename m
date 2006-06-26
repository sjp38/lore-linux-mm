Message-ID: <449F78D5.8040205@yahoo.com.au>
Date: Mon, 26 Jun 2006 16:04:05 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch] 2.6.17: lockless pagecache
References: <20060625163930.GB3006@wotan.suse.de> <449ECE2E.3080804@gmail.com>
In-Reply-To: <449ECE2E.3080804@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Michal Piotrowski wrote:
> Nick Piggin napisaA?(a):
> 
>>Updated lockless pagecache patchset available here:
>>
>>ftp://ftp.kernel.org/pub/linux/kernel/people/npiggin/patches/lockless/2.6.17/lockless.patch.gz
>>
> 
> 
> Here is my fix for this warnings
> WARNING: /lib/modules/2.6.17.1/kernel/fs/ntfs/ntfs.ko needs unknown symbol add_to_page_cache
> WARNING: /lib/modules/2.6.17.1/kernel/fs/ntfs/ntfs.ko needs unknown symbol add_to_page_cache

Thanks. Accidentally nuked that export.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
