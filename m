Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91EE26B025E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 09:00:55 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so219453wma.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 06:00:55 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ah5si4933229wjc.171.2016.11.15.06.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 06:00:53 -0800 (PST)
Date: Tue, 15 Nov 2016 09:00:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/6] mm: khugepaged: fix radix tree node leak in shmem
 collapse error path
Message-ID: <20161115140046.GA993@cmpxchg.org>
References: <20161108095352.GH32353@quack2.suse.cz>
 <20161108161245.GA4020@cmpxchg.org>
 <20161111105921.GC19382@node.shutemov.name>
 <20161111122224.GA5090@quack2.suse.cz>
 <20161111163753.GH19382@node.shutemov.name>
 <20161114080744.GA2524@quack2.suse.cz>
 <20161114142902.GA10455@node.shutemov.name>
 <20161114155250.GB3291@cmpxchg.org>
 <20161114164822.GB5141@cmpxchg.org>
 <20161114194054.GA12829@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161114194054.GA12829@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 14, 2016 at 10:40:54PM +0300, Kirill A. Shutemov wrote:
> Could you just amend all these fixups into your patch?

Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
