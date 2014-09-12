Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C434F6B0037
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 00:59:50 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so407234pad.7
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 21:59:50 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kd4si5662240pbc.12.2014.09.11.21.59.48
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 21:59:49 -0700 (PDT)
Message-ID: <54127DC3.40107@intel.com>
Date: Thu, 11 Sep 2014 21:59:47 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 09/10] x86, mpx: cleanup unused bound tables
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-10-git-send-email-qiaowei.ren@intel.com> <5411B8C3.7080205@intel.com> <9E0BE1322F2F2246BD820DA9FC397ADE017A4015@shsmsx102.ccr.corp.intel.com>
In-Reply-To: <9E0BE1322F2F2246BD820DA9FC397ADE017A4015@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 09/11/2014 08:02 PM, Ren, Qiaowei wrote:
> On 2014-09-11, Hansen, Dave wrote:
>> On 09/11/2014 01:46 AM, Qiaowei Ren wrote:
>>> + * This function will be called by do_munmap(), and the VMAs
>>> + covering
>>> + * the virtual address region start...end have already been split
>>> + if
>>> + * necessary and remvoed from the VMA list.
>>
>> "remvoed" -> "removed"
>>
>>> +void mpx_unmap(struct mm_struct *mm,
>>> +		unsigned long start, unsigned long end) {
>>> +	int ret;
>>> +
>>> +	ret = mpx_try_unmap(mm, start, end);
>>> +	if (ret == -EINVAL)
>>> +		force_sig(SIGSEGV, current);
>>> +}
>> 
>> In the case of a fault during an unmap, this just ignores the 
>> situation and returns silently.  Where is the code to retry the 
>> freeing operation outside of mmap_sem?
> 
> Dave, you mean delayed_work code? According to our discussion, it
> will be deferred to another mainline post.

OK, fine.  Just please call that out in the description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
