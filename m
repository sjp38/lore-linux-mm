Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 246366B0104
	for <linux-mm@kvack.org>; Sun, 23 Feb 2014 14:32:27 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id q108so12672991qgd.10
        for <linux-mm@kvack.org>; Sun, 23 Feb 2014 11:32:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id js6si3814776qcb.51.2014.02.23.11.32.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Feb 2014 11:32:26 -0800 (PST)
Message-ID: <530A4CBE.5090305@oracle.com>
Date: Sun, 23 Feb 2014 14:32:14 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com> <20140131123352.a3da2a1dee32d79ad1f6af9f@linux-foundation.org>
In-Reply-To: <20140131123352.a3da2a1dee32d79ad1f6af9f@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, walken@google.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, vbabka@suse.cz, stable@kernel.org, gregkh@linuxfoundation.org, Bob Liu <bob.liu@oracle.com>

On 01/31/2014 03:33 PM, Andrew Morton wrote:
> On Wed, 18 Dec 2013 08:42:49 +0800 Bob Liu<lliubbo@gmail.com>  wrote:
>
>> >This BUG_ON() was triggered when called from try_to_unmap_cluster() which
>> >didn't lock the page.
>> >And it's safe to mlock_vma_page() without PageLocked, so this patch fix this
>> >issue by removing that BUG_ON() simply.
>> >
> This patch doesn't appear to be going anywhere, so I will drop it.
> Please let's check to see whether the bug still exists and if so, start
> another round of bugfixing.

This bug still happens on the latest -next kernel.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
