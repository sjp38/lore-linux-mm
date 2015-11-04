Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 630D382F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:00:23 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so64648275pab.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:00:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y8si2128439pbt.196.2015.11.04.14.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 14:00:20 -0800 (PST)
Date: Wed, 4 Nov 2015 14:00:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
Message-Id: <20151104140018.2e0a00db747784046822a602@linux-foundation.org>
In-Reply-To: <563A5D0D.9030109@android.com>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
	<20151103160410.34bbebc805c17d2f41150a19@linux-foundation.org>
	<87k2pyppfk.fsf@x220.int.ebiederm.org>
	<20151103173156.9ca17f52.akpm@linux-foundation.org>
	<563A5D0D.9030109@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

On Wed, 4 Nov 2015 11:31:25 -0800 Daniel Cashman <dcashman@android.com> wrote:

> As for the
> clarification itself, where would you like it?  I could include a cover
> letter for this patch-set, elaborate more in the commit message itself,
> add more to the Kconfig help description, or some combination of the above.

In either [0/n] or [x/x] changelog, please.  I routinely move the [0/n]
material into the [1/n] changelog anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
