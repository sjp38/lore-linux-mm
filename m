Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 624126B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 14:58:23 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y8so5249511wrd.0
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 11:58:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e5si4775073edj.426.2017.10.04.11.58.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Oct 2017 11:58:22 -0700 (PDT)
Date: Wed, 4 Oct 2017 14:58:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: tty crash due to auto-failing vmalloc
Message-ID: <20171004185813.GA2136@cmpxchg.org>
References: <20171003225504.GA966@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003225504.GA966@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Okay, how about the following two patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
