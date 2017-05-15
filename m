Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7319F6B02F2
	for <linux-mm@kvack.org>; Mon, 15 May 2017 10:14:02 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u12so112702891pgo.4
        for <linux-mm@kvack.org>; Mon, 15 May 2017 07:14:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y133si10892290pfg.257.2017.05.15.07.14.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 07:14:01 -0700 (PDT)
Subject: Re: [PATCHv5, REBASED 8/9] x86: Enable 5-level paging support
References: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
 <20170515121218.27610-9-kirill.shutemov@linux.intel.com>
 <9af22de7-89f3-576a-f933-c4e593924091@suse.com>
 <20170515141118.wh45ham64unjk5y2@black.fi.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <c4474ae0-9a5e-443f-60f6-8ec0bc72b0d8@suse.com>
Date: Mon, 15 May 2017 16:13:49 +0200
MIME-Version: 1.0
In-Reply-To: <20170515141118.wh45ham64unjk5y2@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 15/05/17 16:11, Kirill A. Shutemov wrote:
> On Mon, May 15, 2017 at 02:31:00PM +0200, Juergen Gross wrote:
>>> diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
>>> index 027987638e98..12205e6dfa59 100644
>>> --- a/arch/x86/xen/Kconfig
>>> +++ b/arch/x86/xen/Kconfig
>>> @@ -5,6 +5,7 @@
>>>  config XEN
>>>  	bool "Xen guest support"
>>>  	depends on PARAVIRT
>>> +	depends on !X86_5LEVEL
>>
>> I'd rather put this under "config XEN_PV".
> 
> Makes sense.
> 
> ----------------------8<----------------------------
> 
> From 422a980c748a5b84a013258eb7c00d61edc34492 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Sat, 5 Nov 2016 03:24:03 +0300
> Subject: [PATCHv6 8/9] x86: Enable 5-level paging support
> 
> Most of things are in place and we can enable support of 5-level paging.
> 
> The patch makes XEN_PV dependent on !X86_5LEVEL. XEN_PV is not ready to
> work with 5-level paging.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Xen part:
Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
