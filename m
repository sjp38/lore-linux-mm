Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C5FE86B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 10:28:53 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so41725832pac.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 07:28:53 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x1si31987pdm.181.2015.05.07.07.28.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 07:28:53 -0700 (PDT)
Message-ID: <554B769E.1040000@parallels.com>
Date: Thu, 7 May 2015 17:28:46 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] UserfaultFD: Rename uffd_api.bits into .features
References: <5509D342.7000403@parallels.com> <20150421120222.GC4481@redhat.com> <55389261.50105@parallels.com> <20150427211650.GC24035@redhat.com> <55425A74.3020604@parallels.com> <20150507134236.GB13098@redhat.com>
In-Reply-To: <20150507134236.GB13098@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>

On 05/07/2015 04:42 PM, Andrea Arcangeli wrote:
> Hi Pavel,
> 
> On Thu, Apr 30, 2015 at 07:38:12PM +0300, Pavel Emelyanov wrote:
>> Hi,
>>
>> This is (seem to be) the minimal thing that is required to unblock
>> standard uffd usage from the non-cooperative one. Now more bits can
>> be added to the features field indicating e.g. UFFD_FEATURE_FORK and
>> others needed for the latter use-case.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> Applied.
> 
> http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=c2dee3384770a953cbad27b46854aa6fd13656c6
> http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=d0df59f21f2cde4c49879c00586ce3cb1e3860fe

Great!

> I was also asked if we could return the full address of the fault
> including the page offset. In the end I also implemented this
> incremental to your change:
> 
> http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=c308fc81b0a9c53c11b33331ad00d8e5b9763e60
> 
> Let me know if you're ok with it. 

Yup, this is very close to what I did in my set -- introduced a message to
report back to the user-space on read. But my message is more than 8+2*1 bytes,
so we'll have one message for 0xAA API and another one for 0xAB (new) one :)

> The commit header explains more why
> I think the bits below PAGE_SHIFT of the fault address aren't
> interesting but why I did this change anyway.
> 
> After reviewing this last change I think it's time to make a proper
> submit and it's polished enough for merging in -mm after proper review
> of the full patchset.

Yup, fully agree :) And I will soon send the re-based non-cooperative patchset
with new API version, longer messages, fork and remap events reporting.

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
