Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 352C46B0010
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 13:26:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 25-v6so14216697pfs.5
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 10:26:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h14-v6si8551350plk.130.2018.10.14.10.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Oct 2018 10:26:07 -0700 (PDT)
Date: Sun, 14 Oct 2018 10:26:04 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 19/25] vfs: implement opportunistic short dedupe
Message-ID: <20181014172604.GH30673@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938927786.8361.10345203650384514542.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153938927786.8361.10345203650384514542.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

How is RFR_SHORT_DEDUPE so different from RFR_SAME_DATA + RFR_CAN_SHORTEN
that we need another flag for it?
