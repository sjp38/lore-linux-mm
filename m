Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED8C6B0260
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:22:09 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id s9so10985723pfe.20
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 08:22:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q17si22798353pgt.617.2017.11.27.08.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 08:22:08 -0800 (PST)
Date: Mon, 27 Nov 2017 08:22:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Message-ID: <20171127162207.GA8265@bombadil.infradead.org>
References: <23066.59196.909026.689706@gargle.gargle.HOWL>
 <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikael Pettersson <mikpelinux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org

On Mon, Nov 27, 2017 at 11:12:32AM +0100, Michal Hocko wrote:
> On Sun 26-11-17 17:09:32, Mikael Pettersson wrote:
> > - Reaching the limit causes various memory management system calls to
> >   fail with ENOMEM, which is a lie.  Combined with the unpredictability
> >   of the number of mappings in a process, especially when non-trivial
> >   memory management or heavy file mapping is used, it can be difficult
> >   to reproduce these events and debug them.  It's also confusing to get
> >   ENOMEM when you know you have lots of free RAM.

[snip]

> Could you be more explicit about _why_ we need to remove this tunable?
> I am not saying I disagree, the removal simplifies the code but I do not
> really see any justification here.

I imagine he started seeing random syscalls failing with ENOMEM and
eventually tracked it down to this stupid limit we used to need.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
