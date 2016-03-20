Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5B3830AE
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 15:00:23 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id l68so128516536wml.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:00:23 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id iq7si19995334wjb.143.2016.03.20.12.00.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 20 Mar 2016 12:00:22 -0700 (PDT)
Date: Sun, 20 Mar 2016 19:00:16 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 01/71] arc: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160320190016.GD17997@ZenIV.linux.org.uk>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458499278-1516-2-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFzSqbT+wQFmpaF+g8snk4AZ7oW7dheOUeqJq2qA5tytrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzSqbT+wQFmpaF+g8snk4AZ7oW7dheOUeqJq2qA5tytrw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>, linux-mm <linux-mm@kvack.org>

On Sun, Mar 20, 2016 at 11:54:56AM -0700, Linus Torvalds wrote:
> I'm OK with this, but let's not do this as a hundred small patches, OK?
> 
> It doesn't help legibility or testing, so let's just do it in one big go.

Might make sense splitting it by the thing being removed, though - easier
to visually verify that it's doing the right thing when all replacements
are of the same sort...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
