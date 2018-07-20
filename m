Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7B5A6B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 19:14:32 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id y16-v6so6789788pgv.23
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:14:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c2-v6si2749290pge.124.2018.07.20.16.14.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 16:14:31 -0700 (PDT)
Date: Fri, 20 Jul 2018 16:14:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: adjust max read count in
 generic_file_buffered_read()
Message-Id: <20180720161429.d63dccb9f66799dc0ff74dba@linux-foundation.org>
In-Reply-To: <20180719085812.sjup2odrjyuigt3l@quack2.suse.cz>
References: <20180719081726.3341-1-cgxu519@gmx.com>
	<20180719085812.sjup2odrjyuigt3l@quack2.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Chengguang Xu <cgxu519@gmx.com>, mgorman@techsingularity.net, jlayton@redhat.com, ak@linux.intel.com, mawilcox@microsoft.com, tim.c.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>

On Thu, 19 Jul 2018 10:58:12 +0200 Jan Kara <jack@suse.cz> wrote:

> On Thu 19-07-18 16:17:26, Chengguang Xu wrote:
> > When we try to truncate read count in generic_file_buffered_read(),
> > should deliver (sb->s_maxbytes - offset) as maximum count not
> > sb->s_maxbytes itself.
> > 
> > Signed-off-by: Chengguang Xu <cgxu519@gmx.com>
> 
> Looks good to me. You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>

Yup.

What are the runtime effects of this bug?
