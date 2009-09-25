Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id ECD286B006A
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 14:25:50 -0400 (EDT)
Received: from ::ffff:72.254.62.73 ([72.254.62.73]) by xenotime.net for <linux-mm@kvack.org>; Fri, 25 Sep 2009 11:25:56 -0700
Message-ID: <4ABD0B74.6080106@xenotime.net>
Date: Fri, 25 Sep 2009 11:27:00 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: Re: [PATCH] memory : adjust the ugly comment
References: <1253870451-4887-1-git-send-email-shijie8@gmail.com> <20090925111913.c7c32a06.akpm@linux-foundation.org>
In-Reply-To: <20090925111913.c7c32a06.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Shijie <shijie8@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 25 Sep 2009 17:20:51 +0800 Huang Shijie <shijie8@gmail.com> wrote:
> 
>> The origin comment is too ugly, so modify it more beautiful.
>>
>> Signed-off-by: Huang Shijie <shijie8@gmail.com>
>> ---
>>  mm/memory.c |    5 ++++-
>>  1 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 7e91b5f..6a38caa 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2405,7 +2405,10 @@ restart:
>>  }
>>  
>>  /**
>> - * unmap_mapping_range - unmap the portion of all mmaps in the specified address_space corresponding to the specified page range in the underlying file.
>> + * unmap_mapping_range - unmap the portion of all mmaps in the specified
>> + *	 		address_space corresponding to the specified page range
>> + * 			in the underlying file.
>> + *
> 
> The comment must all be in a single line so that the kerneldoc tools
> process it correctly.  It's a kerneldoc restriction which all are
> welcome to fix ;)

Patch for that (multi-line "short" function descriptions)
was merged just a few days ago.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=6423133bdee0e07d1c2f8411cb3fe676c207ba33


~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
