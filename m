Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1178E60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 23:12:14 -0500 (EST)
Message-ID: <4B383017.4070308@redhat.com>
Date: Sun, 27 Dec 2009 23:12:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Prevent churning of zero page
 in LRU list.
References: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop> <4B38246C.3020209@redhat.com> <20091228035639.GG3601@balbir.in.ibm.com> <20091228035738.GH3601@balbir.in.ibm.com>
In-Reply-To: <20091228035738.GH3601@balbir.in.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 12/27/2009 10:57 PM, Balbir Singh wrote:
> * Balbir Singh<balbir@linux.vnet.ibm.com>  [2009-12-28 09:26:39]:
>
>> * Rik van Riel<riel@redhat.com>  [2009-12-27 22:22:20]:
>>
>>> On 12/27/2009 09:53 PM, Minchan Kim wrote:
>>>>
>>>> VM doesn't add zero page to LRU list.
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

>> Frequent moving of zero page should ideally put it to the head of the
>> LRU list, leaving it untouched is likely to cause it to be scanned
>> often - no? Should this be moved to the unevictable list?
>>
>
> Sorry, I replied to wrong email, I should have been clearer that this
> question is for Minchan Kim.

The answer to your question is all the way up in
Minchan Kim's original email.

The zero page is never on the LRU lists to begin with.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
