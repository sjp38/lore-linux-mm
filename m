Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 319AC600044
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 00:55:25 -0400 (EDT)
Received: by gyb11 with SMTP id 11so4791721gyb.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 21:55:24 -0700 (PDT)
Message-ID: <4C60DBD5.8090801@vflare.org>
Date: Tue, 10 Aug 2010 10:25:49 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] Reduce per table entry overhead by 4 bytes
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>	<1281374816-904-6-git-send-email-ngupta@vflare.org> <AANLkTikERp9DOpK=1R_UdjuNrS6dbAkX+Q5kysgVcv0k@mail.gmail.com>
In-Reply-To: <AANLkTikERp9DOpK=1R_UdjuNrS6dbAkX+Q5kysgVcv0k@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 08/10/2010 12:29 AM, Pekka Enberg wrote:
> On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
>> Each zram device maintains an array (table) that maps
>> index within the device to the location of corresponding
>> compressed chunk. Currently we store 'struct page' pointer,
>> offset with page and various flags separately which takes
>> 12 bytes per table entry. Now all these are encoded in a
>> single 'phys_add_t' value which results in savings of 4 bytes
>> per entry (except on PAE systems).
>>
>> Unfortunately, cleanups related to some variable renames
>> were mixed in this patch. So, please bear some additional
>> noise.
> 
> The noise makes this patch pretty difficult to review properly. Care
> to spilt the patch into two pieces?
> 

Ok, I will split them as separate patches.

Thanks for all the reviews and Acks.
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
