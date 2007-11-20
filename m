Received: by ro-out-1112.google.com with SMTP id p7so2140296roc
        for <linux-mm@kvack.org>; Mon, 19 Nov 2007 21:00:06 -0800 (PST)
Date: Tue, 20 Nov 2007 12:57:37 +0800
From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] mm/sparse.c: Check the return value of
	sparse_index_alloc().
Message-ID: <20071120045737.GE2472@hacking>
Reply-To: WANG Cong <xiyou.wangcong@gmail.com>
References: <20071115135428.GE2489@hacking> <1195507022.27759.146.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1195507022.27759.146.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 19, 2007 at 01:17:02PM -0800, Dave Hansen wrote:
>On Thu, 2007-11-15 at 21:54 +0800, WANG Cong wrote:
>> Since sparse_index_alloc() can return NULL on memory allocation failure,
>> we must deal with the failure condition when calling it.
>> 
>> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
>> Cc: Christoph Lameter <clameter@sgi.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> 
>> ---
>> 
>> diff --git a/Makefile b/Makefile
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index e06f514..d245e59 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -83,6 +83,8 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>>  		return -EEXIST;
>> 
>>  	section = sparse_index_alloc(nid);
>> +	if (!section)
>> +		return -ENOMEM;
>>  	/*
>>  	 * This lock keeps two different sections from
>>  	 * reallocating for the same index
>
>Oddly enough, sparse_add_one_section() doesn't seem to like to check
>its allocations.  The usemap is checked, but not freed on error.  If you
>want to fix this up, I think it needs a little more love than just two
>lines.  

Er, right. I missed this point.

>
>Do you want to try to add some actual error handling to
>sparse_add_one_section()?

Yes, I will have a try. And memory_present() also doesn't check it.
More patches around this will come up soon. Since Andrew has included
the above patch, so I won't remake it with others together.

Andrew, is this OK for you?

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
