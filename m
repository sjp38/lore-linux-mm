Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 26CAF6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 13:24:29 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id d7so1363795bkh.34
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:24:28 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id ls2si3988805bkb.78.2014.01.24.10.24.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 10:24:28 -0800 (PST)
Received: by mail-ig0-f177.google.com with SMTP id k19so3261174igc.4
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:24:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52E2AEA3.2020907@intel.com>
References: <52E19C7D.7050603@intel.com>
	<CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com>
	<52E28067.1060507@intel.com>
	<CAE9FiQVy+8CF5qwnyL8YGzqwKOJF+y7N_+reAXWw7p8-BaVQPg@mail.gmail.com>
	<52E2AC5A.3000005@intel.com>
	<CAE9FiQW3DrGjKHLhwBgcK076g7z-6_-0EN2HwtVBLSpKO4m6-Q@mail.gmail.com>
	<52E2AEA3.2020907@intel.com>
Date: Fri, 24 Jan 2014 10:24:26 -0800
Message-ID: <CAE9FiQU795SWFfnQU=0STbQconSraac8heCNnkMpynY6fbi-4w@mail.gmail.com>
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 24, 2014 at 10:19 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 01/24/2014 10:13 AM, Yinghai Lu wrote:
>> On Fri, Jan 24, 2014 at 10:09 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>>> On 01/24/2014 09:45 AM, Yinghai Lu wrote:
>>> Here you go.  It's still spitting out memblock_reserve messages to the
>>> console.  I'm not sure if it's making _some_ progress or not.
>>>
>>>         https://www.sr71.net/~dave/intel/3.13/dmesg.with-2-patches
>>>
>>> But, it's certainly not booting.  Do you want to see it without
>>> memblock=debug?
>>
>> that looks like different problem. and it can not set memory mapping properly.
>>
>> can you send me .config ?
>
> Here you go.
>
> FWIW, I did turn of memblock=debug.  It eventually booted, but
> slooooooooooowly.

then that is not a problem, as you are using 4k page mapping only.
and that printout is too spew...

>
> How many problems in this code are we tracking, btw?  This is at least
> 3, right?

two problems:
1. big numa system.
2. Andrew's system with swiotlb.

The two patches should address them.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
