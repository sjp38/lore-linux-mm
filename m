Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id 38E4D6B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 11:11:37 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so2542068eaj.26
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 08:11:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e2si17190046eeg.198.2014.01.11.08.11.35
        for <linux-mm@kvack.org>;
        Sat, 11 Jan 2014 08:11:36 -0800 (PST)
Date: Sat, 11 Jan 2014 17:11:25 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH] mm: thp: Add per-mm_struct flag to control THP
Message-ID: <20140111161125.GA17160@redhat.com>
References: <1389383718-46031-1-git-send-email-athorlton@sgi.com> <20140110202310.GB1421@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140110202310.GB1421@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On 01/10, Kirill A. Shutemov wrote:
>
> I prefer to fix THP instead of
> adding new knob to disable it.

I agree. But if we have the per-vma MADV/VM_ flags, it looks
natural to also have the per-mm know which affects all vmas.

Besides this allows to control the thp behaviour after exec.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
