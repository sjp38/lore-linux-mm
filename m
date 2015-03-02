Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8F66B0070
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 18:10:35 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so12059414pdb.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 15:10:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cw14si3588053pac.189.2015.03.02.15.10.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 15:10:34 -0800 (PST)
Date: Mon, 2 Mar 2015 15:10:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 3/3] hugetlbfs: accept subpool reserved option and setup
 accordingly
Message-Id: <20150302151033.562db79cd3da844392461795@linux-foundation.org>
In-Reply-To: <1425077893-18366-6-git-send-email-mike.kravetz@oracle.com>
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
	<1425077893-18366-6-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Davidlohr Bueso <davidlohr@hp.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 27 Feb 2015 14:58:13 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Make reserved be an option when mounting a hugetlbfs.

New mount option triggers a user documentation update.  hugetlbfs isn't
well documented, but Documentation/vm/hugetlbpage.txt looks like the
place.


> reserved
> option is only possible if size option is also specified.

The code doesn't appear to check for this (maybe it does).  Probably it
should do so, and warn when it fails.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
