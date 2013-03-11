Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 9845B6B0005
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 11:03:24 -0400 (EDT)
Message-ID: <513DF239.2000806@ubuntu.com>
Date: Mon, 11 Mar 2013 11:03:21 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: mmap vs fs cache
References: <5136320E.8030109@symas.com> <20130307154312.GG6723@quack.suse.cz> <20130308020854.GC23767@cmpxchg.org> <5139975F.9070509@symas.com> <20130308084246.GA4411@shutemov.name> <5139B214.3040303@symas.com> <5139FA13.8090305@genband.com> <5139FD27.1030208@symas.com> <513A8ECB.8000504@ubuntu.com> <20130311115220.GB29799@quack.suse.cz>
In-Reply-To: <20130311115220.GB29799@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Howard Chu <hyc@symas.com>, Chris Friesen <chris.friesen@genband.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 3/11/2013 7:52 AM, Jan Kara wrote:
>> Yep, that's because it isn't implemented.
>    Why do you think so? AFAICS it is implemented by setting VM_RAND_READ
> flag in the VMA and do_async_mmap_readahead() and do_sync_mmap_readahead()
> check for the flag and don't do anything if it is set...

Oh, don't know how I missed that... I was just looking for it the other 
day and couldn't find any references to VM_RandomReadHint so I assumed 
it hadn't been implemented.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
