Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 46FBC900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 02:00:24 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id eu11so7039071pac.30
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 23:00:24 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ru12si486999pac.48.2014.10.27.23.00.22
        for <linux-mm@kvack.org>;
        Mon, 27 Oct 2014 23:00:23 -0700 (PDT)
Message-ID: <544F303C.10903@intel.com>
Date: Tue, 28 Oct 2014 13:57:16 +0800
From: Ren Qiaowei <qiaowei.ren@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 10/12] x86, mpx: add prctl commands PR_MPX_ENABLE_MANAGEMENT,
 PR_MPX_DISABLE_MANAGEMENT
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-11-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241436560.5308@nanos> <9E0BE1322F2F2246BD820DA9FC397ADE0180ED65@shsmsx102.ccr.corp.intel.com> <alpine.DEB.2.11.1410272137140.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410272137140.5308@nanos>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>

On 10/28/2014 04:38 AM, Thomas Gleixner wrote:
> On Mon, 27 Oct 2014, Ren, Qiaowei wrote:
>> On 2014-10-24, Thomas Gleixner wrote:
>>> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
>>>> +int mpx_enable_management(struct task_struct *tsk) {
>>>> +	struct mm_struct *mm = tsk->mm;
>>>> +	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
>>>
>>> What's the point of initializing bd_base here. I had to look twice to
>>> figure out that it gets overwritten by task_get_bounds_dir()
>>>
>>
>> I just want to put task_get_bounds_dir() outside mm->mmap_sem holding.
>
> What you want is not interesting at all. What's interesting is what
> you do and what you send for review.
>

I see. Thanks.

- Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
