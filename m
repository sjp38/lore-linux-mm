Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id B05136B0005
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 06:22:21 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 20 Mar 2013 15:47:43 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 841AA3940065
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 15:52:15 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2KAM9Hd3408304
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 15:52:10 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2KAMDQZ018379
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 21:22:14 +1100
Date: Wed, 20 Mar 2013 18:22:10 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/4] introduce zero-filled page stat count
Message-ID: <20130320102210.GA18262@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363255697-19674-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130316130638.GB5987@konrad-lan.dumpdata.com>
 <5145BE06.8070309@gmail.com>
 <CAPbh3rvzuScPorS8Nc0Er33gYrbYNc9cqfPbN2Ca7QkhVSN9hA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPbh3rvzuScPorS8Nc0Er33gYrbYNc9cqfPbN2Ca7QkhVSN9hA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 19, 2013 at 12:41:49PM -0400, Konrad Rzeszutek Wilk wrote:
>On Sun, Mar 17, 2013 at 8:58 AM, Ric Mason <ric.masonn@gmail.com> wrote:
>> Hi Konrad,
>>
>> On 03/16/2013 09:06 PM, Konrad Rzeszutek Wilk wrote:
>>>
>>> On Thu, Mar 14, 2013 at 06:08:16PM +0800, Wanpeng Li wrote:
>>>>
>>>> Introduce zero-filled page statistics to monitor the number of
>>>> zero-filled pages.
>>>
>>> Hm, you must be using an older version of the driver. Please
>>> rebase it against Greg KH's staging tree. This is where most if not
>>> all of the DebugFS counters got moved to a different file.
>>
>>
>> It seems that zcache debugfs in Greg's staging-next is buggy, Could you test
>> it?
>>
>Could you email me what the issue you are seeing?

Hi Konrad,

I think I have already fix them for you in my patchset [PATCH v4 0/8], could you 
review 3/8~6/8, thanks. :-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
