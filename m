Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 279EE6B0260
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 15:57:36 -0400 (EDT)
Received: by mail-io0-f176.google.com with SMTP id 124so38515893iov.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:57:36 -0700 (PDT)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id z18si6901649igq.63.2016.03.20.12.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Mar 2016 12:57:35 -0700 (PDT)
Received: by mail-io0-x244.google.com with SMTP id z140so1270955iof.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:57:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160320193407.GB1907@black.fi.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1458499278-1516-2-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+55aFzSqbT+wQFmpaF+g8snk4AZ7oW7dheOUeqJq2qA5tytrw@mail.gmail.com>
	<20160320190016.GD17997@ZenIV.linux.org.uk>
	<CA+55aFzHPXcQT8XXy7=PAvaaN9d6uzu9JYN0nrtSPYWmr+=bWA@mail.gmail.com>
	<20160320193407.GB1907@black.fi.intel.com>
Date: Sun, 20 Mar 2016 12:57:34 -0700
Message-ID: <CA+55aFy+XcZ8roVhLH2T6bMs9RpykavxFv09yw08yw+LbzDXYg@mail.gmail.com>
Subject: Re: [PATCH 01/71] arc: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>, linux-mm <linux-mm@kvack.org>

On Sun, Mar 20, 2016 at 12:34 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> Hm. Okay. Re-split this way would take some time. I'll post updated
> patchset tomorrow.

Oh, I was assuming this was automated with coccinelle or at least some
simple shell scripting..

Generally, for things like this, automation really is great.

In fact, I like it when people attach the scripts to the commit
message, further clarifying exactly what they did (even if the end
result then often includes manual fixups for patterns that didn't
_quite_ match, or where the automated script just generated ugly
indentation or similar).

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
