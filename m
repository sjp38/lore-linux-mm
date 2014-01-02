Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1C15D6B0035
	for <linux-mm@kvack.org>; Wed,  1 Jan 2014 20:36:29 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so13635391pdj.39
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 17:36:28 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id dv5si40849584pbb.313.2014.01.01.17.36.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Jan 2014 17:36:27 -0800 (PST)
Message-ID: <52C4C216.3070607@huawei.com>
Date: Thu, 2 Jan 2014 09:34:14 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add a new command-line kmemcheck value
References: <52C2811C.4090907@huawei.com> <CAOMGZ=GOR_i9ixvHeHwfDN1wwwSQzFNFGa4qLZMhWWNzx0p8mw@mail.gmail.com>
In-Reply-To: <CAOMGZ=GOR_i9ixvHeHwfDN1wwwSQzFNFGa4qLZMhWWNzx0p8mw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vegard
 Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, wangnan0@huawei.com, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2013/12/31 18:12, Vegard Nossum wrote:

> (Oops, resend to restore Cc.)
> 
> Hi,
> 
> On 31 December 2013 09:32, Xishi Qiu <qiuxishi@huawei.com> wrote:
>> Add a new command-line kmemcheck value: kmemcheck=3 (disable the feature),
>> this is the same effect as CONFIG_KMEMCHECK disabled.
>> After doing this, we can enable/disable kmemcheck feature in one vmlinux.
> 
> Could you please explain what exactly the difference is between the
> existing kmemcheck=0 parameter and the new kmemcheck=3?
> 
> Thanks,
> 
> 
> Vegard
> 

Hi Vegard,

kmemcheck=0: enable kmemcheck feature, but don't check the memory.
	and the OS use only one cpu.(setup_max_cpus = 1)
kmemcheck=3: disable kmemcheck feature.
	this is the same effect as CONFIG_KMEMCHECK disabled.
	OS will use cpus as many as possible.

Thanks,
Xishi Qiu




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
