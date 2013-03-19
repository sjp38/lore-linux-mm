Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 540836B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 19:31:56 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y14so351541pdi.8
        for <linux-mm@kvack.org>; Tue, 19 Mar 2013 16:31:55 -0700 (PDT)
Message-ID: <5148F565.7060809@gmail.com>
Date: Wed, 20 Mar 2013 07:31:49 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/4] introduce zero-filled page stat count
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com> <1363255697-19674-4-git-send-email-liwanp@linux.vnet.ibm.com> <20130316130638.GB5987@konrad-lan.dumpdata.com> <5145BE06.8070309@gmail.com> <CAPbh3rvzuScPorS8Nc0Er33gYrbYNc9cqfPbN2Ca7QkhVSN9hA@mail.gmail.com>
In-Reply-To: <CAPbh3rvzuScPorS8Nc0Er33gYrbYNc9cqfPbN2Ca7QkhVSN9hA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad@darnok.org
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/20/2013 12:41 AM, Konrad Rzeszutek Wilk wrote:
> On Sun, Mar 17, 2013 at 8:58 AM, Ric Mason <ric.masonn@gmail.com> wrote:
>> Hi Konrad,
>>
>> On 03/16/2013 09:06 PM, Konrad Rzeszutek Wilk wrote:
>>> On Thu, Mar 14, 2013 at 06:08:16PM +0800, Wanpeng Li wrote:
>>>> Introduce zero-filled page statistics to monitor the number of
>>>> zero-filled pages.
>>> Hm, you must be using an older version of the driver. Please
>>> rebase it against Greg KH's staging tree. This is where most if not
>>> all of the DebugFS counters got moved to a different file.
>>
>> It seems that zcache debugfs in Greg's staging-next is buggy, Could you test
>> it?
>>
> Could you email me what the issue you are seeing?
They have already fixed in Wanpeng's patchset v4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
