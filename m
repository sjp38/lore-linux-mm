Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A78DF6B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 11:48:15 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id z8-v6so8003407itc.9
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 08:48:15 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k197-v6si5260702ite.36.2018.07.02.08.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 02 Jul 2018 08:48:14 -0700 (PDT)
Subject: Re: [PATCH] x86: make Memory Management options more visible
References: <af12c83d-2533-ae00-b53c-1fc1a9d8e9ce@infradead.org>
 <20180702140612.GA7333@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <afcb4a42-891a-d732-f072-79c0a1fc49f0@infradead.org>
Date: Mon, 2 Jul 2018 08:48:10 -0700
MIME-Version: 1.0
In-Reply-To: <20180702140612.GA7333@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On 07/02/2018 07:06 AM, Christoph Hellwig wrote:
> On Sun, Jul 01, 2018 at 07:48:38PM -0700, Randy Dunlap wrote:
>> From: Randy Dunlap <rdunlap@infradead.org>
>>
>> Currently for x86, the "Memory Management" kconfig options are
>> displayed under "Processor type and features."  This tends to
>> make them hidden or difficult to find.
>>
>> This patch makes Memory Managment options a first-class menu by moving
>> it away from "Processor type and features" and into the main menu.
>>
>> Also clarify "endmenu" lines with '#' comments of their respective
>> menu names, just to help people who are reading or editing the
>> Kconfig file.
>>
>> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> 
> Hmm, can you take off from this for now and/or rebase it on top of
> this series:
> 
> 	http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/kconfig-cleanups
> 

Sure, no problem.

-- 
~Randy
