Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id AB69E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 12:41:51 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t11so597188wey.28
        for <linux-mm@kvack.org>; Tue, 19 Mar 2013 09:41:50 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <5145BE06.8070309@gmail.com>
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<1363255697-19674-4-git-send-email-liwanp@linux.vnet.ibm.com>
	<20130316130638.GB5987@konrad-lan.dumpdata.com>
	<5145BE06.8070309@gmail.com>
Date: Tue, 19 Mar 2013 12:41:49 -0400
Message-ID: <CAPbh3rvzuScPorS8Nc0Er33gYrbYNc9cqfPbN2Ca7QkhVSN9hA@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] introduce zero-filled page stat count
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Mar 17, 2013 at 8:58 AM, Ric Mason <ric.masonn@gmail.com> wrote:
> Hi Konrad,
>
> On 03/16/2013 09:06 PM, Konrad Rzeszutek Wilk wrote:
>>
>> On Thu, Mar 14, 2013 at 06:08:16PM +0800, Wanpeng Li wrote:
>>>
>>> Introduce zero-filled page statistics to monitor the number of
>>> zero-filled pages.
>>
>> Hm, you must be using an older version of the driver. Please
>> rebase it against Greg KH's staging tree. This is where most if not
>> all of the DebugFS counters got moved to a different file.
>
>
> It seems that zcache debugfs in Greg's staging-next is buggy, Could you test
> it?
>
Could you email me what the issue you are seeing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
