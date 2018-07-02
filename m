Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9622D6B0008
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 11:57:46 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id s16-v6so12126934ybp.12
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 08:57:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f5-v6sor53983yba.196.2018.07.02.08.57.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 08:57:45 -0700 (PDT)
Date: Mon, 2 Jul 2018 08:57:43 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] writeback: update stale account_page_redirty() comment
Message-ID: <20180702155743.GE533219@devbig577.frc2.facebook.com>
References: <20180625171526.173483-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180625171526.173483-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 25, 2018 at 10:15:26AM -0700, Greg Thelen wrote:
> commit 93f78d882865 ("writeback: move backing_dev_info->bdi_stat[] into
> bdi_writeback") replaced BDI_DIRTIED with WB_DIRTIED in
> account_page_redirty().  Update comment to track that change.
>   BDI_DIRTIED => WB_DIRTIED
>   BDI_WRITTEN => WB_WRITTEN
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
