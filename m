Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1D76B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:46:49 -0400 (EDT)
Received: by obdeg2 with SMTP id eg2so18659680obd.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 08:46:49 -0700 (PDT)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id g5si7133824obv.79.2015.07.24.08.46.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 08:46:48 -0700 (PDT)
Message-ID: <55B25DDE.8090107@roeck-us.net>
Date: Fri, 24 Jul 2015 08:46:38 -0700
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: [PATCH V4 2/6] mm: mlock: Add new mlock, munlock, and munlockall
 system calls
References: <1437508781-28655-1-git-send-email-emunson@akamai.com> <1437508781-28655-3-git-send-email-emunson@akamai.com> <20150721134441.d69e4e1099bd43e56835b3c5@linux-foundation.org> <1437528316.16792.7.camel@ellerman.id.au> <20150722141501.GA3203@akamai.com> <20150723065830.GA5919@linux-mips.org> <20150724143936.GE9203@akamai.com>
In-Reply-To: <20150724143936.GE9203@akamai.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Ralf Baechle <ralf@linux-mips.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mips@linux-mips.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-am33-list@redhat.com, Geert Uytterhoeven <geert@linux-m68k.org>, Vlastimil Babka <vbabka@suse.cz>, linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 07/24/2015 07:39 AM, Eric B Munson wrote:
> On Thu, 23 Jul 2015, Ralf Baechle wrote:
>
>> On Wed, Jul 22, 2015 at 10:15:01AM -0400, Eric B Munson wrote:
>>
>>>>
>>>> You haven't wired it up properly on powerpc, but I haven't mentioned it because
>>>> I'd rather we did it.
>>>>
>>>> cheers
>>>
>>> It looks like I will be spinning a V5, so I will drop all but the x86
>>> system calls additions in that version.
>>
>> The MIPS bits are looking good however, so
>>
>> Acked-by: Ralf Baechle <ralf@linux-mips.org>
>>
>> With my ack, will you keep them or maybe carry them as a separate patch?
>
> I will keep the MIPS additions as a separate patch in the series, though
> I have dropped two of the new syscalls after some discussion.  So I will
> not include your ack on the new patch.
>
> Eric
>

Hi Eric,

next-20150724 still has some failures due to this patch set. Are those
being looked at (I know parisc builds fail, but there may be others) ?

Thanks,
Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
