Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C838282F6C
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 14:36:11 -0500 (EST)
Received: by padhx2 with SMTP id hx2so53488805pad.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 11:36:11 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id re6si4099424pab.143.2015.11.04.11.36.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 11:36:11 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so37250019pac.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 11:36:11 -0800 (PST)
Subject: Re: [PATCH v2 1/2] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
 <20151104093957.GA31378@dhcp22.suse.cz>
 <877flxo9j5.fsf@x220.int.ebiederm.org>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <563A5E27.2060607@android.com>
Date: Wed, 4 Nov 2015 11:36:07 -0800
MIME-Version: 1.0
In-Reply-To: <877flxo9j5.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

On 11/4/15 11:21 AM, Eric W. Biederman wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
>> On Tue 03-11-15 10:10:03, Daniel Cashman wrote:
>> [...]
>>> +This value can be changed after boot using the
>>> +/proc/sys/kernel/mmap_rnd_bits tunable
>>
>> Why is this not sitting in /proc/sys/vm/ where we already have
>> mmap_min_addr. These two sound like they should sit together, no?
> 
> Ugh.  Yes.  Moving that file before it becomes part of the ABI sounds
> like a good idea.  Daniel when you get around to v3 please move the
> file.

To answer the first question: it was put there because that's where
randomize_va_space is located, which seemed to me to be the
most-related/similar option.  That being said, moving it under vm works
too.  Will change for patch-set 3.

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
