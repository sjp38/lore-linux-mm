Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 817ED6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 04:27:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p46so6139294wrb.1
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 01:27:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor6413030edi.48.2017.10.03.01.27.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 01:27:57 -0700 (PDT)
Date: Tue, 3 Oct 2017 11:27:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171003082754.no6ym45oirah53zp@node.shutemov.name>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 29, 2017 at 05:08:15PM +0300, Kirill A. Shutemov wrote:
> The first bunch of patches that prepare kernel to boot-time switching
> between paging modes.
> 
> Please review and consider applying.

Ping?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
