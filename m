Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9F086B000D
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 13:24:37 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id l7-v6so13575255plg.6
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 10:24:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w16-v6si7684531pge.9.2018.10.14.10.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Oct 2018 10:24:36 -0700 (PDT)
Date: Sun, 14 Oct 2018 10:24:33 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 16/25] vfs: make remapping to source file eof more
 explicit
Message-ID: <20181014172433.GG30673@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938925737.8361.3995899966552253527.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153938925737.8361.3995899966552253527.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Fri, Oct 12, 2018 at 05:07:37PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Create a RFR_TO_SRC_EOF flag to explicitly declare that the caller wants
> the remap implementation to remap to the end of the source file, once
> the files are locked.

The name looks like a cat threw up on your keyboard :)

>From reading the code this seems to ask for a whole file remap, right?
Why not put that in the name to make it more descriptive?
