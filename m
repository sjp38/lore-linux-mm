Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5500A6B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 03:25:19 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q71so19532417qkl.2
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 00:25:19 -0700 (PDT)
Received: from edison.jonmasters.org (edison.jonmasters.org. [173.255.233.168])
        by mx.google.com with ESMTPS id i135si12898150qka.57.2017.04.25.00.25.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Apr 2017 00:25:18 -0700 (PDT)
References: <030ea57b-5f6c-13d8-02f7-b245a754a87d@physik.fu-berlin.de>
 <20170424161959.c5ba2nhnxyy57wxe@node.shutemov.name>
 <fdc80e3c-6909-cf39-fe0b-6f1c012571e4@physik.fu-berlin.de>
 <20170424.180948.1311847745777709716.davem@davemloft.net>
From: Jon Masters <jcm@jonmasters.org>
Message-ID: <eb59ccee-f479-ef42-ebf5-f2fde2776709@jonmasters.org>
Date: Tue, 25 Apr 2017 03:25:09 -0400
MIME-Version: 1.0
In-Reply-To: <20170424.180948.1311847745777709716.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Subject: Re: Question on the five-level page table support patches
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, glaubitz@physik.fu-berlin.de
Cc: kirill@shutemov.name, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, ak@linux.intel.com, dave.hansen@intel.com, luto@amacapital.net, mhocko@suse.com, linux-arch@vger.kernel.org, linux-mm@kvack.org

On 04/24/2017 06:09 PM, David Miller wrote:
> From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> Date: Mon, 24 Apr 2017 22:37:40 +0200
> 
>> Would be really nice to able to have a canonical solution for this issue,
>> it's been biting us on SPARC for quite a while now due to the fact that
>> virtual address space has been 52 bits on SPARC for a while now.
> 
> It's going to break again with things like ADI which encode protection
> keys in the high bits of the 64-bit virtual address.
> 
> Reallly, it would be nice if these tags were instead encoded in the
> low bits of suitably aligned memory allocations but I am sure it's to
> late to do that now.

I'm curious (and hey, ARM has 52-bit VAs coming[0] that was added in
ARMv8.2). Does anyone really think pointer tagging is a good idea for a
new architecture being created going forward? This could be archived
somewhere so that the folks in Berkeley and elsewhere have an answer.

As an aside, one of the reasons I've been tracking these Intel patches
personally is to figure out the best way to play out the ARMv8 story.
There isn't the same legacy of precompiled code out there (and the
things that broke and were fixed when moving from 42-bit to 48-bit VA
are already accounting for a later switch to 52-bit). I do find it
amusing that I proposed a solution similar Kirill's a year or so back to
some other folks elsewhere with a similar set of goals in mind.

Jon.

[0] Requires 64K pages on ARMv8. It's one of the previously unmentioned
reasons why RHEL for ARM was built with 64K granule size ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
