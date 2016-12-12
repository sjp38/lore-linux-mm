Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA8EC6B0260
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 12:51:39 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xy5so27610229wjc.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 09:51:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o7si45388818wjw.219.2016.12.12.09.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 09:51:38 -0800 (PST)
Date: Mon, 12 Dec 2016 12:51:33 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/6 v3] dax: Page invalidation fixes
Message-ID: <20161212175133.GB8688@cmpxchg.org>
References: <20161212164708.23244-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161212164708.23244-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Mon, Dec 12, 2016 at 05:47:02PM +0100, Jan Kara wrote:
> Hello,
> 
> this is the third revision of my fixes of races when invalidating hole pages in
> DAX mappings. See changelogs for details. The series is based on my patches to
> write-protect DAX PTEs which are currently carried in mm tree. This is a hard
> dependency because we really need to closely track dirtiness (and cleanness!)
> of radix tree entries in DAX mappings in order to avoid discarding valid dirty
> bits leading to missed cache flushes on fsync(2).
> 
> The tests have passed xfstests for xfs and ext4 in DAX and non-DAX mode.
> 
> Johannes, are you OK with patch 2/6 in its current form? I'd like to push these
> patches to some tree once DAX write-protection patches are merged.  I'm hoping
> to get at least first three patches merged for 4.10-rc2... Thanks!

LGTM, thanks Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
