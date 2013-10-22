Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0BEE36B00DC
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 19:58:32 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so224194pab.12
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:32 -0700 (PDT)
Received: from psmtp.com ([74.125.245.132])
        by mx.google.com with SMTP id ad7si166364pbd.328.2013.10.22.16.58.31
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 16:58:31 -0700 (PDT)
Message-ID: <1382486304.2041.103.camel@joe-AO722>
Subject: Re: [PATCH 00/24] treewide: Convert use of typedef ctl_table to
 struct ctl_table
From: Joe Perches <joe@perches.com>
Date: Tue, 22 Oct 2013 16:58:24 -0700
In-Reply-To: <52670FF4.8070701@gmail.com>
References: <cover.1382480758.git.joe@perches.com>
	 <52670FF4.8070701@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Daney <ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-rdma@vger.kernel.org, linux-raid@vger.kernel.org, linux-scsi@vger.kernel.org, codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, keyrings@linux-nfs.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

On Tue, 2013-10-22 at 16:53 -0700, David Daney wrote:
> After all this work, why not go ahead and remove the typedef?  That way 
> people won't add more users of this abomination.

Hi David.

The typedef can't be removed until all the uses are gone.

I've sent this before as a single large patch as well as
individual patches.

treewide:	https://lkml.org/lkml/2013/7/22/600
RemoveTypedef:	https://lkml.org/lkml/2013/7/22/603

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
