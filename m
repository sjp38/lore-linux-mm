Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id AB3346B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 21:41:16 -0400 (EDT)
Message-ID: <52326D37.8040400@redhat.com>
Date: Thu, 12 Sep 2013 21:41:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] ANB(Automatic NUMA Balancing): erase mm footprint
 of migrated page
References: <20130913004538.A7AA3428001@webmail.sinamail.sina.com.cn>
In-Reply-To: <20130913004538.A7AA3428001@webmail.sinamail.sina.com.cn>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhillf@sina.com
Cc: Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

On 09/12/2013 08:45 PM, Hillf Danton wrote:
> If a page monitored by ANB is migrated, its footprint should be erased from
> numa-hint-fault account, because it is no longer used. Or two pages, the
> migrated page and its target page, are used in the view of task placement.
> 
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

NAK

The numa faults buffer contains the number of pages on each
node that the task recently faulted on.

If the page got migrated, it is only counted on the new node,
not on the old one. That means there is no need to subtract
it on the old node.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
