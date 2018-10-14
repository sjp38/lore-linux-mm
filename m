Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5DE6B0266
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 13:37:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r72-v6so13690999pfj.3
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 10:37:42 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e21-v6si8012317pgl.305.2018.10.14.10.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Oct 2018 10:37:41 -0700 (PDT)
Date: Sun, 14 Oct 2018 10:37:38 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 11/25] vfs: pass remap flags to
 generic_remap_file_range_prep
Message-ID: <20181014173738.GA6400@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938921860.8361.1983470639945895613.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153938921860.8361.1983470639945895613.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

> +	bool is_dedupe = (remap_flags & RFR_SAME_DATA);

Btw, I think the code would be cleaner if we dropped this variable.
