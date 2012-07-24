Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 5865F6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 20:55:14 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 23 Jul 2012 18:55:11 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0E0213E40039
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 00:54:48 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6O0sm7X162302
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 18:54:48 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6O0smCl026394
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 18:54:48 -0600
Date: Tue, 24 Jul 2012 08:54:45 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH RESEND v4 1/3] mm/sparse: optimize sparse_index_alloc
Message-ID: <20120724005445.GA4393@shangw.(null)>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1343010702-28720-1-git-send-email-shangw@linux.vnet.ibm.com>
 <juj1bs$qh3$1@dough.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <juj1bs$qh3$1@dough.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org

On Mon, Jul 23, 2012 at 08:18:04AM +0000, Cong Wang wrote:
>On Mon, 23 Jul 2012 at 02:31 GMT, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
>> With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
>> descriptors are allocated from slab or bootmem. When allocating
>> from slab, let slab/bootmem allocator to clear the memory chunk.
>> We needn't clear that explicitly.
>>
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>> Acked-by: David Rientjes <rientjes@google.com>
>
>Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
>

Thanks for your time, Cong :-)

Thanks,
Gavin

>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
