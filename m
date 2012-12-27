Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id CB3B26B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 10:42:46 -0500 (EST)
Date: Thu, 27 Dec 2012 16:42:39 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <50D24AF3.1050809@iskon.hr> <50D24CD9.8070507@iskon.hr> <CAJd=RBCQN1GxOUCwGPXL27d_q8hv50uHK5LhDnsv7mdv_2Usaw@mail.gmail.com>
In-Reply-To: <CAJd=RBCQN1GxOUCwGPXL27d_q8hv50uHK5LhDnsv7mdv_2Usaw@mail.gmail.com>
Message-ID: <50DC6C6F.6050703@iskon.hr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm: do not sleep in balance_pgdat if there's no i/o congestion
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 21.12.2012 12:51, Hillf Danton wrote:
> On Thu, Dec 20, 2012 at 7:25 AM, Zlatko Calusic <zlatko.calusic@iskon.hr> wrote:
>>   static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>>                                                          int *classzone_idx)
>>   {
>> -       int all_zones_ok;
>> +       struct zone *unbalanced_zone;
>
> nit: less hunks if not erase that mark
>
> Hillf

This one left unanswered and forgotten because I didn't understand what 
you meant. Could you elaborate?

-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
