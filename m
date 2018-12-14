Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26C748E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 23:53:58 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 202so3009386pgb.6
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 20:53:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j20si3126565pgh.224.2018.12.13.20.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 20:53:56 -0800 (PST)
Date: Thu, 13 Dec 2018 20:53:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/6] mm: migrate: Provide buffer_migrate_page_norefs()
Message-Id: <20181213205353.561d4f22fdb92efe57719b69@linux-foundation.org>
In-Reply-To: <20181211172143.7358-5-jack@suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
	<20181211172143.7358-5-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mhocko@suse.cz, mgorman@suse.de

On Tue, 11 Dec 2018 18:21:41 +0100 Jan Kara <jack@suse.cz> wrote:

> Provide a variant of buffer_migrate_page() that also checks whether
> there are no unexpected references to buffer heads. This function will
> then be safe to use for block device pages.
> 
> ...
>
> +EXPORT_SYMBOL(buffer_migrate_page_norefs);

The export is presently unneeded and I don't think we expect that this
will be used by anything other than fs/block_dev.c?
