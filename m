Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDAB6B00BF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 07:22:30 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id o8so10406009qcw.38
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 04:22:30 -0800 (PST)
Received: from n23.mail01.mtsvc.net (mailout32.mail01.mtsvc.net. [216.70.64.70])
        by mx.google.com with ESMTPS id s4si488365qcq.11.2014.11.04.04.22.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Nov 2014 04:22:29 -0800 (PST)
Message-ID: <5458C501.3040505@hurleysoftware.com>
Date: Tue, 04 Nov 2014 07:22:25 -0500
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: alloc_contig_range: demote pages busy message from
 warn to info
References: <2457604.k03RC2Mv4q@avalon> <1415033873-28569-1-git-send-email-mina86@mina86.com> <20141104054307.GA23102@bbox>
In-Reply-To: <20141104054307.GA23102@bbox>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/04/2014 12:43 AM, Minchan Kim wrote:
> Hello,
> 
> On Mon, Nov 03, 2014 at 05:57:53PM +0100, Michal Nazarewicz wrote:
>> Having test_pages_isolated failure message as a warning confuses
>> users into thinking that it is more serious than it really is.  In
>> reality, if called via CMA, allocation will be retried so a single
>> test_pages_isolated failure does not prevent allocation from
>> succeeding.
>>
>> Demote the warning message to an info message and reformat it such
>> that the text a??faileda?? does not appear and instead a less worrying
>> a??PFNS busya?? is used.
> 
> What do you expect from this message? Please describe it so that we can
> review below message helps your goal.

I expect this message to not show up in logs unless there is a real problem.

This message is trivially reproducible on a 10GB x86 machine on 3.16.y
kernels configured with CONFIG_DMA_CMA.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
