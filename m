Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 67E5E6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 05:10:35 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so49178549pab.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 02:10:35 -0800 (PST)
Received: from olympic.calvaedi.com (olympic.calvaedi.com. [89.202.194.163])
        by mx.google.com with ESMTPS id ez3si1062745pab.130.2015.11.04.02.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 02:10:33 -0800 (PST)
Message-ID: <5639D98A.80308@calva.com>
Date: Wed, 04 Nov 2015 11:10:18 +0100
From: John Hughes <john@calva.com>
MIME-Version: 1.0
Subject: Re: [Bug 107111] New: page allocation failure but there seem to be
 free pages
References: <bug-107111-27@https.bugzilla.kernel.org/> <20151103141603.261893b44e0cd6e704921fb6@linux-foundation.org>
In-Reply-To: <20151103141603.261893b44e0cd6e704921fb6@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On 03/11/15 23:16, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).

OK.
>
> On Tue, 03 Nov 2015 16:21:06 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=107111
>>
>>              Bug ID: 107111
>>             Summary: page allocation failure but there seem to be free
>>                      pages
>>             Product: Memory Management
>>             Version: 2.5
>>      Kernel Version: 4.2.3
>>            Hardware: IA-64
>> 18
> Note: IA64.  It isn't tested much and perhaps this triggered an oddity.

Sorry, user error, it's x86-64, not IA64, a KVM guest running on a 
"Intel(R) Xeon(R) CPU            3050".

> The kernel could and should have satisfied this order-1 GFP_ATOMIC
> IRQ-context allocation from the DMA zone.  But it did not do so.  Bug.

Looking back in my kern.logs I confirm that I've only seen this on 
kernel 4.2.3, never on the 3.18.19 I was running up to 16/10/2015. It 
happens up to 15 times a day, and, so far, hasn't happened since I upped 
/proc/sys/vm/min_free_kbytes to 8192.

-- 
John Hughes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
