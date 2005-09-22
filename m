Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH 1/4] hugetlbfs: move free_inodes accounting
Date: Wed, 21 Sep 2005 23:37:55 -0700
Message-ID: <B05667366EE6204181EABE9C1B1C0EB508378531@scsmsx401.amr.corp.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>
Cc: viro@ftp.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote on Wednesday, September 21, 2005 11:11 PM
> Does anyone remember why we have special-case handling in there for
> (sbinfo->free_inodes < 0)?

We encode -1 in sbinfo->free_inodes at the time of mount to indicate
unlimited nr_inodes for hugetlbfs mount point.  For unlimited nr_inodes
mount option, we won't update free_inodes field.  (unlimited nr_inodes
option could be an overkill for hugetlbfs)

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
