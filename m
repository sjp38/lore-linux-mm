Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2FD76B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 04:20:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so89236382lfw.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 01:20:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u4si20196315wmf.121.2016.08.02.01.20.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 01:20:48 -0700 (PDT)
Subject: Re: [PATCH 08/10] x86, pkeys: default to a restrictive init PKRU
References: <20160729163009.5EC1D38C@viggo.jf.intel.com>
 <20160729163021.F3C25D4A@viggo.jf.intel.com>
 <cd74ae8b-36e4-a397-e36f-fe3d4281d400@suse.cz> <579F6380.2070600@sr71.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <95491d2d-35cf-ebf9-a34e-0405def707e2@suse.cz>
Date: Tue, 2 Aug 2016 10:20:41 +0200
MIME-Version: 1.0
In-Reply-To: <579F6380.2070600@sr71.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, dave.hansen@linux.intel.com, arnd@arndb.de

On 08/01/2016 04:58 PM, Dave Hansen wrote:
> On 08/01/2016 07:42 AM, Vlastimil Babka wrote:
>> On 07/29/2016 06:30 PM, Dave Hansen wrote:
>>> This does not cause any practical problems with applications
>>> using protection keys because we require them to specify initial
>>> permissions for each key when it is allocated, which override the
>>> restrictive default.
>>
>> Here you mean the init_access_rights parameter of pkey_alloc()? So will
>> children of fork() after that pkey_alloc() inherit the new value or go
>> default?
>
> Hi Vlastimil,
>
> Yes, exactly, the initial permissions are provided via pkey_alloc()'s
> 'init_access_rights' argument.

OK. I was a bit sceptical of that part of the syscall, as you removed 
other syscalls changing PKRU for the thread in kernel, so leaving this 
seemed odd. But it makes sense to me together with the restrictive default.

> Do you mean fork() or clone()?  In both cases, we actually copy the FPU
> state from the parent, so children always inherit the state from their
> parent which contains the permissions set by the parent's calls to
> pkey_alloc().

I meant just fork() as I misunderstood the changelog in that clone() is 
different. Thanks for clarifying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
