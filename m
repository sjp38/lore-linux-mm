Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7BDA46B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 03:12:43 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e23-v6so3439726oii.10
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 00:12:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t187-v6si1812131oie.262.2018.07.18.00.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 00:12:42 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6I78df4031217
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 03:12:41 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ka03k21ky-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 03:12:41 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Jul 2018 08:12:38 +0100
Date: Wed, 18 Jul 2018 10:12:31 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: kernel BUG at fs/userfaultfd.c:LINE! (2)
References: <000000000000dcb1a1057112c66a@google.com>
 <20180717192806.GI75957@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717192806.GI75957@gmail.com>
Message-Id: <20180718071230.GA4302@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, syzbot <syzbot+121be635a7a35ddb7dcb@syzkaller.appspotmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk

On Tue, Jul 17, 2018 at 12:28:06PM -0700, Eric Biggers wrote:
> [+Cc userfaultfd developers and linux-mm]
> 
> The reproducer hits the BUG_ON() in userfaultfd_release():
> 
> 	BUG_ON(!!vma->vm_userfaultfd_ctx.ctx ^
> 	       !!(vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP)));

Thanks for the CC.

The fix is below.

--
Sincerely yours,
Mike.
