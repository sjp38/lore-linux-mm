Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id A4C176B007E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 17:04:01 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id vv3so89158622pab.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 14:04:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h10si7165058paw.142.2016.04.27.14.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 14:04:00 -0700 (PDT)
Date: Wed, 27 Apr 2016 14:03:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: put activate_page_pvecs and others pagevec together
Message-Id: <20160427140359.a5003280ef5c6bda149ee141@linux-foundation.org>
In-Reply-To: <tencent_5CF8AA8413F8563C681F8DC9@qq.com>
References: <tencent_5CF8AA8413F8563C681F8DC9@qq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Li <mingli199x@qq.com>
Cc: Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <Babkavbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon, 11 Apr 2016 09:36:46 +0800 "Ming Li" <mingli199x@qq.com> wrote:

> hi, i`m sorry, I made some mistakes in last email. I have been studying mm and learn age_activate_anon(), at the very beginning I felt confuse when I saw activate_page_pvecs, after I learned the whole thing I understood that it's similar with other pagevec's function. Can we put it with other pagevec together? I think it is easier for newbies to read and understand.

Welcome to kernel development ;)

Your email client is mangling the patches in several ways.  Please sort
that out for next time - mail yourself a patch, check that it applies.

The changelog text wasn't very conventional.  I rewrote it to

: Put the activate_page_pvecs definition next to those of the other
: pagevecs, for clarity.

and I changed the title to 

Subject: mm/swap.c: put activate_page_pvecs and other pagevecs together

because "mm" is a big place!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
