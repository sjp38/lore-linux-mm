Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 932988E01C5
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 04:26:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so2510434edb.1
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 01:26:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4si1574052edr.163.2018.12.14.01.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 01:26:27 -0800 (PST)
Date: Fri, 14 Dec 2018 10:26:25 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/6] mm: migrate: Provide buffer_migrate_page_norefs()
Message-ID: <20181214092625.GC8896@quack2.suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-5-jack@suse.cz>
 <20181213205353.561d4f22fdb92efe57719b69@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213205353.561d4f22fdb92efe57719b69@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mhocko@suse.cz, mgorman@suse.de

On Thu 13-12-18 20:53:53, Andrew Morton wrote:
> On Tue, 11 Dec 2018 18:21:41 +0100 Jan Kara <jack@suse.cz> wrote:
> 
> > Provide a variant of buffer_migrate_page() that also checks whether
> > there are no unexpected references to buffer heads. This function will
> > then be safe to use for block device pages.
> > 
> > ...
> >
> > +EXPORT_SYMBOL(buffer_migrate_page_norefs);
> 
> The export is presently unneeded and I don't think we expect that this
> will be used by anything other than fs/block_dev.c?

Good point. We can always re-add the export if someone needs it. Thanks for
removing it!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
