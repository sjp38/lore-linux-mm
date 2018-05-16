Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEFCD6B0349
	for <linux-mm@kvack.org>; Wed, 16 May 2018 13:30:17 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p14-v6so1081088wre.21
        for <linux-mm@kvack.org>; Wed, 16 May 2018 10:30:17 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 6-v6si2528857wri.310.2018.05.16.10.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 10:30:16 -0700 (PDT)
Date: Wed, 16 May 2018 19:34:45 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 14/14] mm: turn on vm_fault_t type checking
Message-ID: <20180516173445.GA6088@lst.de>
References: <20180516054348.15950-1-hch@lst.de> <20180516054348.15950-15-hch@lst.de> <20180516150829.GA4904@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516150829.GA4904@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 08:08:29AM -0700, Darrick J. Wong wrote:
> Uh, we're changing function signatures /and/ redefinining vm_fault_t?
> All in the same 90K patch?
> 
> I /was/ expecting a series of "convert XXXXX and all callers/users"
> patches followed by a trivial one to switch the definition, not a giant
> pile of change.  FWIW I don't mind so much if you make a patch
> containing a change for some super-common primitive and a hojillion
> little diff hunks tree-wide, but only one logical change at a time for a
> big patch, please...
> 
> I quite prefer seeing the whole series from start to finish all packaged
> up in one series, but wow this was overwhelming. :/

Another vote to split the change of the typedef, ok I get the message..
