Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 4160B6B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 09:51:09 -0400 (EDT)
Message-ID: <520A39A4.6090407@oracle.com>
Date: Tue, 13 Aug 2013 21:50:28 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/4] mm: add WasActive page flag
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com> <1375788977-12105-5-git-send-email-bob.liu@oracle.com> <5209CBA1.2080009@iki.fi>
In-Reply-To: <5209CBA1.2080009@iki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, gregkh@linuxfoundation.org, ngupta@vflare.org, akpm@linux-foundation.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org

Hi Pekka,

On 08/13/2013 02:01 PM, Pekka Enberg wrote:
> On 8/6/13 2:36 PM, Bob Liu wrote:
>> Zcache could be ineffective if the compressed memory pool is full with
>> compressed inactive file pages and most of them will be never used again.
>>
>> So we pick up pages from active file list only, those pages would
>> probably be
>> accessed again. Compress them in memory can reduce the latency
>> significantly
>> compared with rereading from disk.
>>
>> When a file page is shrinked from active file list to inactive file list,
>> PageActive flag is also cleared.
>> So adding an extra WasActive page flag for zcache to know whether the
>> file page
>> was shrinked from the active list.
>>
>> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> 

Thank you so much for your review!

> Using a page flag for this seems like an ugly hack to me.
> Can we rearrange the code so that vmscan notifies zcache
> *before* the active page flag is cleared...?

Yep, adding a page flag is not a good idea.
I'm looking at whether there is other way to notify zcache.

BTW: Could you please give some feedback too about other zcache patches?

> 
>                 Pekka

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
