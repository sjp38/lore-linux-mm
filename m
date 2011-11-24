Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B3A1C6B00A7
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 22:18:30 -0500 (EST)
Message-ID: <4ECDB778.30006@redhat.com>
Date: Thu, 24 Nov 2011 11:18:16 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
References: <1322038412-29013-1-git-send-email-amwang@redhat.com> <alpine.LSU.2.00.1111231100110.2226@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1111231100110.2226@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'11ae??24ae?JPY 03:07, Hugh Dickins a??e??:
> On Wed, 23 Nov 2011, Cong Wang wrote:
>> +
>> +	while (index<  end) {
>> +		ret = shmem_getpage(inode, index,&page, SGP_WRITE, NULL);
>> +		if (ret) {
>> +			if (ret == -ENOSPC)
>> +				goto undo;
> ...
>> +undo:
>> +	while (index>  start) {
>> +		shmem_truncate_page(inode, index);
>> +		index--;
>> +	}
>
> As I said before, I won't actually be reviewing and testing this for
> a week or two; but before this goes any further, must point out how
> wrong it is.  Here you'll be deleting any pages in the range that were
> already present before the failing fallocate().

Ah, I totally missed this. So, is there any way to tell if the page
gotten from shmem_getpage() is newly allocated or not?

I will dig the code...

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
