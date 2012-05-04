Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 90EB46B0044
	for <linux-mm@kvack.org>; Thu,  3 May 2012 22:24:58 -0400 (EDT)
Message-ID: <4FA33DF6.8060107@kernel.org>
Date: Fri, 04 May 2012 11:24:54 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-3-git-send-email-minchan@kernel.org> <4FA28907.9020300@vflare.org> <4FA2A2F0.3030509@linux.vnet.ibm.com>
In-Reply-To: <4FA2A2F0.3030509@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On 05/04/2012 12:23 AM, Seth Jennings wrote:

> On 05/03/2012 08:32 AM, Nitin Gupta wrote:
> 
>> On 5/3/12 2:40 AM, Minchan Kim wrote:
>>> We should use zs_handle instead of void * to avoid any
>>> confusion. Without this, users may just treat zs_malloc return value as
>>> a pointer and try to deference it.
>>>
>>> Cc: Dan Magenheimer<dan.magenheimer@oracle.com>
>>> Cc: Konrad Rzeszutek Wilk<konrad.wilk@oracle.com>
>>> Signed-off-by: Minchan Kim<minchan@kernel.org>
>>> ---
>>>   drivers/staging/zcache/zcache-main.c     |    8 ++++----
>>>   drivers/staging/zram/zram_drv.c          |    8 ++++----
>>>   drivers/staging/zram/zram_drv.h          |    2 +-
>>>   drivers/staging/zsmalloc/zsmalloc-main.c |   28
>>> ++++++++++++++--------------
>>>   drivers/staging/zsmalloc/zsmalloc.h      |   15 +++++++++++----
>>>   5 files changed, 34 insertions(+), 27 deletions(-)
>>
>> This was a long pending change. Thanks!
> 
> 
> The reason I hadn't done it before is that it introduces a checkpatch
> warning:
> 
> WARNING: do not add new typedefs
> #303: FILE: drivers/staging/zsmalloc/zsmalloc.h:19:
> +typedef void * zs_handle;
> 


Yes. I did it but I think we are (a) of chapter 5: Typedefs in Documentation/CodingStyle.

 (a) totally opaque objects (where the typedef is actively used to _hide_
     what the object is).

No?

> In addition this particular patch has a checkpatch error:
> 
> ERROR: "foo * bar" should be "foo *bar"
> #303: FILE: drivers/staging/zsmalloc/zsmalloc.h:19:
> +typedef void * zs_handle;


It was my mistake. Will fix.
Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
