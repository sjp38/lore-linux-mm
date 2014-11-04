Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 249A56B00AF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 09:19:53 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id dc16so9768782qab.20
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 06:19:52 -0800 (PST)
Received: from n23.mail01.mtsvc.net (mailout32.mail01.mtsvc.net. [216.70.64.70])
        by mx.google.com with ESMTPS id f2si995322qas.11.2014.11.04.06.19.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Nov 2014 06:19:51 -0800 (PST)
Message-ID: <5458E084.2060208@hurleysoftware.com>
Date: Tue, 04 Nov 2014 09:19:48 -0500
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: alloc_contig_range: demote pages busy message from
 warn to info
References: <2457604.k03RC2Mv4q@avalon> <1415033873-28569-1-git-send-email-mina86@mina86.com> <20141104054307.GA23102@bbox> <5458C501.3040505@hurleysoftware.com> <xa1tvbmv6qco.fsf@mina86.com>
In-Reply-To: <xa1tvbmv6qco.fsf@mina86.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/04/2014 08:35 AM, Michal Nazarewicz wrote:
> On Tue, Nov 04 2014, Peter Hurley <peter@hurleysoftware.com> wrote:
>> On 11/04/2014 12:43 AM, Minchan Kim wrote:
>>> Hello,
>>>
>>> On Mon, Nov 03, 2014 at 05:57:53PM +0100, Michal Nazarewicz wrote:
>>>> Having test_pages_isolated failure message as a warning confuses
>>>> users into thinking that it is more serious than it really is.  In
>>>> reality, if called via CMA, allocation will be retried so a single
>>>> test_pages_isolated failure does not prevent allocation from
>>>> succeeding.
>>>>
>>>> Demote the warning message to an info message and reformat it such
>>>> that the text a??faileda?? does not appear and instead a less worrying
>>>> a??PFNS busya?? is used.
>>>
>>> What do you expect from this message? Please describe it so that we can
>>> review below message helps your goal.
>>
>> I expect this message to not show up in logs unless there is a real problem.
> 
> So frankly I don't care.  Feel free to send a patch removing the message
> all together.  I'll be happy to ack it.

I'd rather just remove CMA allocation from the iommu providers on x86.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
