Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0019F6B0003
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 16:31:43 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t123so339335wmt.2
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 13:31:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k9sor50482wrh.87.2018.02.27.13.31.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Feb 2018 13:31:42 -0800 (PST)
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
From: lazytyped <lazytyped@gmail.com>
Message-ID: <089e9c52-f623-085a-4d8b-d91cfc6a3608@gmail.com>
Date: Tue, 27 Feb 2018 22:31:38 +0100
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Ilya Smith <blackzert@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>



On 2/27/18 9:52 PM, Kees Cook wrote:
> I'd like more details on the threat model here; if it's just a matter
> of .so loading order, I wonder if load order randomization would get a
> comparable level of uncertainty without the memory fragmentation,

This also seems to assume that leaking the address of one single library
isn't enough to mount a ROP attack to either gain enough privileges or
generate a primitive that can leak further information. Is this really
the case? Do you have some further data around this?


A A A A A A  -A  twiz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
