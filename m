Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1D5800C7
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 16:22:05 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 65so162935673pff.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 13:22:05 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sw10si34479379pab.55.2016.01.04.13.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 13:22:04 -0800 (PST)
Date: Mon, 4 Jan 2016 13:22:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: BUG: Bad rss-counter state mm:ffff8800c5a96000 idx:3 val:3894
Message-Id: <20160104132203.6e4f59fd0d1734bd92133ca2@linux-foundation.org>
In-Reply-To: <20151224171253.GA3148@hudson.localdomain>
References: <20151224171253.GA3148@hudson.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremiah Mahler <jmmahler@gmail.com>
Cc: linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Will Drewry <wad@chromium.org>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>

On Thu, 24 Dec 2015 09:12:53 -0800 Jeremiah Mahler <jmmahler@gmail.com> wrote:

> all,
> 
> I have started seeing a "Bad rss-counter" message in the logs with
> the latest linux-next 20151222+.
> 
>   [  458.282192] BUG: Bad rss-counter state mm:ffff8800c5a96000 idx:3 val:3894
> 
> I can test patches if anyone has any ideas.
> 
> -- 
> - Jeremiah Mahler

Thanks.  cc's added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
