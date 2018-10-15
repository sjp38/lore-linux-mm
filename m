Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 980EC6B0279
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:42:30 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id be11-v6so9338461plb.2
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:42:30 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id v17-v6si10676210pgh.35.2018.10.15.08.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 08:42:29 -0700 (PDT)
Date: Mon, 15 Oct 2018 08:42:08 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 11/25] vfs: pass remap flags to
 generic_remap_file_range_prep
Message-ID: <20181015154208.GH28243@magnolia>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938921860.8361.1983470639945895613.stgit@magnolia>
 <20181014173738.GA6400@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181014173738.GA6400@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Sun, Oct 14, 2018 at 10:37:38AM -0700, Christoph Hellwig wrote:
> > +	bool is_dedupe = (remap_flags & RFR_SAME_DATA);
> 
> Btw, I think the code would be cleaner if we dropped this variable.

Ok to both.  I'll move up the patch to replace is_dedupe with
remap_flags to avoid churning the _touch function too, btw.

--D
