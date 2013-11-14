Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C0D886B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 04:57:47 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fa1so1853305pad.2
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 01:57:47 -0800 (PST)
Received: from psmtp.com ([74.125.245.184])
        by mx.google.com with SMTP id sd2si26982928pbb.319.2013.11.14.01.50.39
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 01:51:10 -0800 (PST)
Message-ID: <52849CD2.4030406@elastichosts.com>
Date: Thu, 14 Nov 2013 09:50:10 +0000
From: Alin Dobre <alin.dobre@elastichosts.com>
MIME-Version: 1.0
Subject: Re: Unnecessary mass OOM kills on Linux 3.11 virtualization host
References: <20131024224326.GA19654@alpha.arachsys.com> <20131025103946.GA30649@alpha.arachsys.com> <20131028082825.GA30504@alpha.arachsys.com> <52836002.5050901@elastichosts.com> <20131113120948.GE2834@moon> <52837216.1090100@elastichosts.com> <20131113131921.GF2834@moon>
In-Reply-To: <20131113131921.GF2834@moon>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org

On 13/11/13 13:19, Cyrill Gorcunov wrote:
> On Wed, Nov 13, 2013 at 12:35:34PM +0000, Alin Dobre wrote:
>> On 13/11/13 12:09, Cyrill Gorcunov wrote:
>>> On Wed, Nov 13, 2013 at 11:18:26AM +0000, Alin Dobre wrote:
>>>>
>>>> The above traces seem similar with the ones that were reported by
>>>> Dave couple of months ago in the LKML thread
>>>> https://lkml.org/lkml/2013/8/7/27.
>>>>
>>>> Any further thoughts on why this happens?
>>>
>>> Dave's report has been addressed in commit 6dec97dc9, which is
>>> in 3.11, also you're to have CONFIG_MEM_SOFT_DIRTY=y to trigger
>>> it in former case.
>>
>> Thanks a lot, Cyrill. That's a really good piece of information, we
>> must have missed it although it was clearly there.
>>
>> In the meantime, we will try to reproduce the problem and see if
>> this fix together with CONFIG_MEM_SOFT_DIRTY=y works for our OOM
>> kills also.
>
> Hi Alin, actually if your config has no CONFIG_MEM_SOFT_DIRTY=y
> then the fix won't help, it might be some different issue (Dave
> has been testing the kernel with soft-dirty option set). But of
> course I don't mind if you test the kernel with soft dirty option
> turned on.

Thanks Cyrill! We'll test the kernel anyway to try and reproduce the 
mass oom killing, so we'll see from there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
