Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA61C6B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 23:11:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id q29-v6so4616344edd.0
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 20:11:19 -0700 (PDT)
Received: from mx1.molgen.mpg.de (mx3.molgen.mpg.de. [141.14.17.11])
        by mx.google.com with ESMTPS id l9-v6si1192297edi.372.2018.10.03.20.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 20:11:18 -0700 (PDT)
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
 <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
 <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
 <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic>
From: Paul Menzel <pmenzel@molgen.mpg.de>
Message-ID: <18bf13a4-2853-358e-594f-27533193757c@molgen.mpg.de>
Date: Thu, 4 Oct 2018 05:11:17 +0200
MIME-Version: 1.0
In-Reply-To: <20181003212255.GB28361@zn.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

Dear Borislav,

Am 03.10.2018 um 23:22 schrieb Borislav Petkov:
> On Fri, Sep 28, 2018 at 04:55:19PM +0200, Thomas Gleixner wrote:
>> Sorry for the delay and thanks for the data. A quick diff did not reveal
>> anything obvious. I'll have a closer look and we probably need more (other)
>> information to nail that down.
> 
> Just a brain dump of what I've found out so far.

Thank you for looking into this. On what board are you able to reproduce 
this? Do you build for 32-bit or 64-bit?


Kind regards,

Paul
