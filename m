Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BF6F75F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 06:58:32 -0400 (EDT)
Message-ID: <49D9E054.8090502@redhat.com>
Date: Mon, 06 Apr 2009 13:58:28 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1238855722-32606-1-git-send-email-ieidus@redhat.com> <1238855722-32606-2-git-send-email-ieidus@redhat.com> <1238855722-32606-3-git-send-email-ieidus@redhat.com> <1238855722-32606-4-git-send-email-ieidus@redhat.com> <1238855722-32606-5-git-send-email-ieidus@redhat.com> <20090406091348.GA18464@ports.donpac.ru>
In-Reply-To: <20090406091348.GA18464@ports.donpac.ru>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrey Panin wrote:
> On 094, 04 04, 2009 at 05:35:22PM +0300, Izik Eidus wrote:
>
> <SNIP>
>
>   
>> +static inline u32 calc_checksum(struct page *page)
>> +{
>> +	u32 checksum;
>> +	void *addr = kmap_atomic(page, KM_USER0);
>> +	checksum = jhash(addr, PAGE_SIZE, 17);
>>     
>
> Why jhash2() is not used here ? It's faster and leads to smaller code size.
>   

Beacuse i didnt know, i will check that and change.

Thanks.

(We should really use in cpu crc for Intel Nehalem, and dirty bit for 
the rest of the architactures...)

>   
>> +	kunmap_atomic(addr, KM_USER0);
>> +	return checksum;
>> +}
>>     
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
