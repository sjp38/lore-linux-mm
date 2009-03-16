Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 05EE36B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 08:55:05 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 28so1632844wfa.11
        for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:55:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090316211830.1FE8.A69D9226@jp.fujitsu.com>
References: <20090316105945.18131.82359.stgit@warthog.procyon.org.uk>
	 <20090316120224.GA16506@infradead.org>
	 <20090316211830.1FE8.A69D9226@jp.fujitsu.com>
Date: Mon, 16 Mar 2009 21:55:03 +0900
Message-ID: <28c262360903160555u402b4c34nf273951a207826a2@mail.gmail.com>
Subject: Re: [PATCH] Point the UNEVICTABLE_LRU config option at the
	documentation
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@infradead.org>, David Howells <dhowells@redhat.com>, lee.schermerhorn@hp.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

size vmlinux
   text	   data	    bss	    dec	    hex	filename
6232681	 747665	 708608	7688954	 7552fa	vmlinux

size vmlinux.unevictable
   text	   data	    bss	    dec	    hex	filename
6239404	 747985	 708608	7695997	 756e7d	vmlinux.unevictable

It almost increases about 7K.
Many embedded guys always have a concern about size although it is very small.
It's important about embedded but may not be about server.

In addition, CONFIG_UNEVICTABLE_LRU feature don't have a big impact in
embedded machines which have a very small ram.
I guess many embedded guys will not use this feature.

So, I don't want to remove this configurable option.
Lets not add useless size bloat in embedded system.


On Mon, Mar 16, 2009 at 9:22 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Mon, Mar 16, 2009 at 10:59:45AM +0000, David Howells wrote:
>> > Point the UNEVICTABLE_LRU config option at the documentation describing the
>> > option.
>>
>> Didn't we decide a while ago that the option is pointless and the code
>> should always be enabled?
>
> Yeah.
> CONFIG_UNEVICTABLE_LRU lost existing reason by David's good patch recently.
>
> if nobody of nommu user post bug report in .30 age, I plan to remove
> this config option at .31 age.
>
> his patch is really really good job.
>
>
>
>



-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
