Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BCC196B0023
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:31:25 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id u7so60861603pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 06:31:25 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id cm4si3787182pad.81.2015.12.22.06.31.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 06:31:24 -0800 (PST)
Subject: Re: arch/x86/xen/suspend.c:70:9: error: implicit declaration of
 function 'xen_pv_domain'
References: <201512210015.cGubDgTR%fengguang.wu@intel.com>
 <20151221140704.e376871cd786498eb5e71352@linux-foundation.org>
 <alpine.DEB.2.02.1512221142200.3096@kaball.uk.xensource.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <56795EB1.4080203@oracle.com>
Date: Tue, 22 Dec 2015 09:31:13 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1512221142200.3096@kaball.uk.xensource.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Sasha Levin <sasha.levin@oracle.com>, kbuild-all@01.org, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, David Vrabel <david.vrabel@citrix.com>

On 12/22/2015 06:49 AM, Stefano Stabellini wrote:
> On Mon, 21 Dec 2015, Andrew Morton wrote:
>> On Mon, 21 Dec 2015 00:43:17 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>>
>>> First bad commit (maybe != root cause):
>>>
>>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>>> head:   69c37a92ddbf79d9672230f21a04580d7ac2f4c3
>>> commit: 71458cfc782eafe4b27656e078d379a34e472adf kernel: add support for gcc 5
>>> date:   1 year, 2 months ago
>>> config: x86_64-randconfig-x006-201551 (attached as .config)
>>> reproduce:
>>>          git checkout 71458cfc782eafe4b27656e078d379a34e472adf
>>>          # save the attached .config to linux build tree
>>>          make ARCH=x86_64
>>>
>>> All errors (new ones prefixed by >>):
>>>
>>>     arch/x86/xen/suspend.c: In function 'xen_arch_pre_suspend':
>>>>> arch/x86/xen/suspend.c:70:9: error: implicit declaration of function 'xen_pv_domain' [-Werror=implicit-function-declaration]
>>>          if (xen_pv_domain())
>>>              ^
>> hm, tricky!
>>
>> --- a/arch/x86/xen/suspend.c~arch-x86-xen-suspendc-include-xen-xenh
>> +++ a/arch/x86/xen/suspend.c
>> @@ -1,6 +1,7 @@
>>   #include <linux/types.h>
>>   #include <linux/tick.h>
>>   
>> +#include <xen/xen.h>
>>   #include <xen/interface/xen.h>
>>   #include <xen/grant_table.h>
>>   #include <xen/events.h>
>
> Looks like the right fix. David? Boris?

Why are we trying to compile this if CONFIG_XEN is not set?

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
