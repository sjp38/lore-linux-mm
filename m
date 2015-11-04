Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id BC3CC6B0255
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 04:40:00 -0500 (EST)
Received: by wikq8 with SMTP id q8so88354124wik.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 01:40:00 -0800 (PST)
Received: from mail-wi0-f194.google.com (mail-wi0-f194.google.com. [209.85.212.194])
        by mx.google.com with ESMTPS id pe3si647643wjb.62.2015.11.04.01.39.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 01:39:59 -0800 (PST)
Received: by wimw14 with SMTP id w14so444575wim.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 01:39:59 -0800 (PST)
Date: Wed, 4 Nov 2015 10:39:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
Message-ID: <20151104093957.GA31378@dhcp22.suse.cz>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446574204-15567-1-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

On Tue 03-11-15 10:10:03, Daniel Cashman wrote:
[...]
> +This value can be changed after boot using the
> +/proc/sys/kernel/mmap_rnd_bits tunable

Why is this not sitting in /proc/sys/vm/ where we already have
mmap_min_addr. These two sound like they should sit together, no?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
