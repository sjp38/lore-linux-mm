Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 497436B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 12:58:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s16-v6so4835133pfm.1
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:58:00 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 203-v6si56036968pfc.21.2018.06.07.09.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 09:57:59 -0700 (PDT)
Subject: Re: [PATCH 7/9] x86/mm: Shadow stack page fault error checking
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
 <20180607143705.3531-8-yu-cheng.yu@intel.com>
 <CALCETrXA--XrVNvPM4-Cv6-E6OFd=TZ5Gw_MWePt7MtqCBBqRg@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5764865a-1dd2-ec5b-c67c-1ea322aea203@linux.intel.com>
Date: Thu, 7 Jun 2018 09:56:36 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrXA--XrVNvPM4-Cv6-E6OFd=TZ5Gw_MWePt7MtqCBBqRg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On 06/07/2018 09:26 AM, Andy Lutomirski wrote:
>>
>> +       /*
>> +        * Verify X86_PF_SHSTK is within a shadow stack VMA.
>> +        * It is always an error if there is a shadow stack
>> +        * fault outside a shadow stack VMA.
>> +        */
>> +       if (error_code & X86_PF_SHSTK) {
>> +               if (!(vma->vm_flags & VM_SHSTK))
>> +                       return 1;
>> +               return 0;
>> +       }
>> +
> What, if anything, would go wrong without this change?  It seems like
> it might be purely an optimization.  If so, can you mention that in
> the comment?

This is a fine exercise.  I'm curious what it does, too.

But, I really like it being explicit in the end.  If we depend on
implicit behavior, I really worry that someone breaks it accidentally.
