Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 24FDC6B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:13:33 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id j8so192253qah.0
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 19:13:32 -0800 (PST)
Message-ID: <5126E253.2030105@gmail.com>
Date: Fri, 22 Feb 2013 11:13:23 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: Questin about swap_slot free and invalidate page
References: <20130131051140.GB23548@blaptop> <alpine.LNX.2.00.1302031732520.4050@eggly.anvils> <20130204024950.GD2688@blaptop> <d6fc41b7-8448-40be-84c3-c24d0833bd85@default> <51236C11.1010208@gmail.com> <1f089254-3abe-4c63-a72a-c9e564ae7d0d@default> <51242F0D.4040201@gmail.com> <7793705b-a076-4c5a-be4d-9572d7560860@default>
In-Reply-To: <7793705b-a076-4c5a-be4d-9572d7560860@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 02/22/2013 05:42 AM, Dan Magenheimer wrote:
>> From: Ric Mason [mailto:ric.masonn@gmail.com]
>> Subject: Re: Questin about swap_slot free and invalidate page
>>
>> On 02/19/2013 11:27 PM, Dan Magenheimer wrote:
>>>> From: Ric Mason [mailto:ric.masonn@gmail.com]
>>>>> Hugh is right that handling the possibility of duplicates is
>>>>> part of the tmem ABI.  If there is any possibility of duplicates,
>>>>> the ABI defines how a backend must handle them to avoid data
>>>>> coherency issues.
>>>>>
>>>>> The kernel implements an in-kernel API which implements the tmem
>>>>> ABI.  If the frontend and backend can always agree that duplicate
>>>> Which ABI in zcache implement that?
>>> https://oss.oracle.com/projects/tmem/dist/documentation/api/tmemspec-v001.pdf
>>>
>>> The in-kernel APIs are frontswap and cleancache.  For more information about
>>> tmem, see http://lwn.net/Articles/454795/
>> But you mentioned that you have in-kernel API which can handle
>> duplicate.  Do you mean zcache_cleancache/frontswap_put_page? I think
>> they just overwrite instead of optional flush the page on the
>> second(duplicate) put as mentioned in your tmemspec.
> Maybe I am misunderstanding your question...  The spec allows
> overwrite (and return success) OR flush the page (and return
> failure).  Zcache does the latter (flush).  The code that implements
> it is in tmem_put.

Thanks for your point out.  Pers pages can have duplicate put since swap 
cache page can be reused. Can eph pages also have duplicate put? If yes, 
when can happen?

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
