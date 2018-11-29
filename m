Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 571C06B5386
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 11:32:37 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 41so2201636qto.17
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 08:32:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p127sor1140533qke.59.2018.11.29.08.32.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 08:32:36 -0800 (PST)
Subject: Re: stable request: mm: mlock: avoid increase mm->locked_vm on
 mlock() when already mlock2(,MLOCK_ONFAULT)
References: <CABdQkv_qGi7x4mQjH_mwGGnJs9F85CETOv9HLv=xvQVSPL_N3Q@mail.gmail.com>
 <20181108172557.GE8097@sasha-vm>
From: Rafael David Tinoco <rafael.tinoco@linaro.org>
Message-ID: <d6077494-79d9-c0b0-4264-4121a47406b5@linaro.org>
Date: Thu, 29 Nov 2018 14:32:30 -0200
MIME-Version: 1.0
In-Reply-To: <20181108172557.GE8097@sasha-vm>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org
Cc: Rafael David Tinoco <rafael.tinoco@linaro.org>, gregkh@linuxfoundation.org, stable@vger.kernel.org, kirill.shutemov@linux.intel.com, wei.guo.simon@gmail.com, akpm@linux-foundation.org

On 11/8/18 3:25 PM, Sasha Levin wrote:
> + linux-mm@

Thanks Sasha,

> 
> This is actually upstream commit
> b155b4fde5bdde9fed439cd1f5ea07173df2ed31.
> 
> On Thu, Nov 08, 2018 at 08:07:35AM -0200, Rafael David Tinoco wrote:
>> Hello Greg,
>>
>> Could you please consider backporting to v4.4 the following commit:
>>
>> commit b5b5b6fe643391209b08528bef410e0cf299b826
>> Author: Simon Guo <wei.guo.simon@gmail.com>
>> Date:   Fri Oct 7 20:59:40 2016
>>
>>    mm: mlock: avoid increase mm->locked_vm on mlock() when already
>> mlock2(,MLOCK_ONFAULT)
>>
>> It seems to be a trivial fix for:
>>
>> https://bugs.linaro.org/show_bug.cgi?id=4043
>> (mlock203.c LTP test failing on v4.4)
>>

ping ?

Related bug: https://bugs.linaro.org/show_bug.cgi?id=4043

v4.4 only.

Thank you!
-- 
Rafael D. Tinoco
Linaro Kernel Validation
