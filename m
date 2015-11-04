Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A48AA82F66
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 14:30:04 -0500 (EST)
Received: by padhx2 with SMTP id hx2so53351486pad.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 11:30:04 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id d3si4072193pas.132.2015.11.04.11.30.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 11:30:03 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
	<20151104093957.GA31378@dhcp22.suse.cz>
Date: Wed, 04 Nov 2015 13:21:34 -0600
In-Reply-To: <20151104093957.GA31378@dhcp22.suse.cz> (Michal Hocko's message
	of "Wed, 4 Nov 2015 10:39:58 +0100")
Message-ID: <877flxo9j5.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v2 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Cashman <dcashman@android.com>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

Michal Hocko <mhocko@kernel.org> writes:

> On Tue 03-11-15 10:10:03, Daniel Cashman wrote:
> [...]
>> +This value can be changed after boot using the
>> +/proc/sys/kernel/mmap_rnd_bits tunable
>
> Why is this not sitting in /proc/sys/vm/ where we already have
> mmap_min_addr. These two sound like they should sit together, no?

Ugh.  Yes.  Moving that file before it becomes part of the ABI sounds
like a good idea.  Daniel when you get around to v3 please move the
file.

Thank you,
Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
