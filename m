Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 596CB6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:29:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v14so5786853wmf.6
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:29:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r1si3012430wme.62.2017.06.05.15.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:29:08 -0700 (PDT)
Date: Mon, 5 Jun 2017 15:29:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc: Trivial typo fix.
Message-Id: <20170605152905.3bf55d05ecdb91224b460197@linux-foundation.org>
In-Reply-To: <20170605062248.GC9248@dhcp22.suse.cz>
References: <20170605014350.1973-1-richard.weiyang@gmail.com>
	<20170605062248.GC9248@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, trivial@kernel.org, linux-mm@kvack.org

On Mon, 5 Jun 2017 08:22:48 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 05-06-17 09:43:50, Wei Yang wrote:
> > Looks there is no word "blamo", and it should be "blame".
> > 
> > This patch just fix the typo.
> 
> Well, I do not think this is a typo. blamo has a slang meaning which I
> believe was intentional.

It should be "blammo".

> Besides that, why would you want to fix this
> anyway. Is this something that you would grep for?

Yup.  I wouldn't object to an incidental fix if someone was altering
something else nearby or as part of a file-wide "clean up comments"
patch, but it doesn't seem worth an entire commit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
