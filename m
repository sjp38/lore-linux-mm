Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9D2900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 02:01:28 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so5344436pad.11
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 23:01:28 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id p1si393241pdp.169.2014.10.27.23.01.27
        for <linux-mm@kvack.org>;
        Mon, 27 Oct 2014 23:01:27 -0700 (PDT)
Message-ID: <544F307D.7090701@intel.com>
Date: Tue, 28 Oct 2014 13:58:21 +0800
From: Ren Qiaowei <qiaowei.ren@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound
 violation information
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241408360.5308@nanos> <9E0BE1322F2F2246BD820DA9FC397ADE0180ED16@shsmsx102.ccr.corp.intel.com> <alpine.DEB.2.11.1410272135420.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410272135420.5308@nanos>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>

On 10/28/2014 04:36 AM, Thomas Gleixner wrote:
> On Mon, 27 Oct 2014, Ren, Qiaowei wrote:
>> On 2014-10-24, Thomas Gleixner wrote:
>>> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
>>>
>>>> This patch sets bound violation fields of siginfo struct in #BR
>>>> exception handler by decoding the user instruction and constructing
>>>> the faulting pointer.
>>>>
>>>> This patch does't use the generic decoder, and implements a limited
>>>> special-purpose decoder to decode MPX instructions, simply because
>>>> the generic decoder is very heavyweight not just in terms of
>>>> performance but in terms of interface -- because it has to.
>>>
>>> My question still stands why using the existing decoder is an issue.
>>> Performance is a complete non issue in case of a bounds violation and
>>> the interface argument is just silly, really.
>>>
>>
>> As hpa said, we only need to decode several mpx instructions
>> including BNDCL/BNDCU, and general decoder looks like a little
>> heavy. Peter, what do you think about it?
>
> You're repeating yourself. Care to read the discussion about this from
> the last round of review again?
>

Ok. I will go through it again. Thanks.

- Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
