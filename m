Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0CA8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 07:34:06 -0500 (EST)
Received: by qwa26 with SMTP id 26so518567qwa.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 04:33:13 -0800 (PST)
Message-ID: <4D382B99.7070005@vflare.org>
Date: Thu, 20 Jan 2011 07:33:29 -0500
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] zcache: page cache compression support
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org 20110110131626.GA18407@shutemov.name> <9e7aa896-ed1f-4d50-8227-3a922be39949@default>
In-Reply-To: <9e7aa896-ed1f-4d50-8227-3a922be39949@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 01/18/2011 12:53 PM, Dan Magenheimer wrote:
>> From: Kirill A. Shutemov [mailto:kirill@shutemov.name]
>> Sent: Monday, January 10, 2011 6:16 AM
>> To: Nitin Gupta
>> Cc: Pekka Enberg; Hugh Dickins; Andrew Morton; Greg KH; Dan
>> Magenheimer; Rik van Riel; Avi Kivity; Christoph Hellwig; Minchan Kim;
>> Konrad Rzeszutek Wilk; linux-mm; linux-kernel
>> Subject: Re: [PATCH 0/8] zcache: page cache compression support
>>
>> Hi,
>>
>> What is status of the patchset?
>> Do you have updated patchset with fixes?
>>
>> --
>>   Kirill A. Shutemov
> I wanted to give Nitin a week to respond, but I guess he
> continues to be offline.
>

Sorry, I was on post-exam-vacations, so couldn't
look into it much :)

> I believe zcache is completely superceded by kztmem.
> Kztmem, like zcache, is dependent on cleancache
> getting merged.
>
> Kztmem may supercede zram also although frontswap (which
> kztmem uses for a more dynamic in-memory swap compression)
> and zram have some functional differences that support
> both being merged.
>
> For latest kztmem patches and description, see:
>
> https://lkml.org/lkml/2011/1/18/170
>

I just started looking into kztmem (weird name!) but on
the high level it seems so much similar to zcache with some
dynamic resizing added (callback for shrinker interface).

Now, I'll try rebuilding zcache according to new cleancache
API as provided by these set of patches. This will help refresh
whatever issues I was having back then with pagecache
compression and maybe pick useful bits/directions from
new kztmem work.

(PAM etc. synonyms make kztmem code reading quite heavy, and
I still don't like frontswap approach but unfortunately do not yet
have any better alternatives ready yet).

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
