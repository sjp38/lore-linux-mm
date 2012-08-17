Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A7C326B005A
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:48:02 -0400 (EDT)
Received: by yenl1 with SMTP id l1so4520798yen.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 22:48:01 -0700 (PDT)
Message-ID: <502DDB0E.8070001@vflare.org>
Date: Thu, 16 Aug 2012 22:47:58 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] zram/zsmalloc promotion
References: <1344406340-14128-1-git-send-email-minchan@kernel.org> <20120814023530.GA9787@kroah.com> <20120814062246.GB31621@bbox>
In-Reply-To: <20120814062246.GB31621@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jens Axboe <jaxboe@fusionio.com>

On 08/13/2012 11:22 PM, Minchan Kim wrote:
> Hi Greg,
> 
> On Mon, Aug 13, 2012 at 07:35:30PM -0700, Greg Kroah-Hartman wrote:
>> On Wed, Aug 08, 2012 at 03:12:13PM +0900, Minchan Kim wrote:
>>> This patchset promotes zram/zsmalloc from staging.
>>> Both are very clean and zram is used by many embedded product
>>> for a long time.
>>>
>>> [1-3] are patches not merged into linux-next yet but needed
>>> it as base for [4-5] which promotes zsmalloc.
>>> Greg, if you merged [1-3] already, skip them.
>>
>> I've applied 1-3 and now 4, but that's it, I can't apply the rest
> 
> Thanks!
> 
>> without getting acks from the -mm maintainers, sorry.  Please work with
> 
> Nitin suggested zsmalloc could be in /lib or /zram out of /mm but I want
> to confirm it from akpm so let's wait his opinion.
> 

akpm, please?

> Anyway, another question. zram would be under driver/blocks.
> Do I need ACK from Jens for that?
> 

Added Jens to CC list.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
