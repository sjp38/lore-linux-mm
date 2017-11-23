Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67D086B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 09:07:39 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y41so11889658wrc.22
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:07:39 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t5si5095289edb.424.2017.11.23.06.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 06:07:38 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vANE4OLj028918
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 09:07:36 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2edx7nv7bf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 09:07:36 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 23 Nov 2017 14:07:34 -0000
Date: Thu, 23 Nov 2017 16:07:25 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 4/4] test: add a test for the process_vmsplice syscall
References: <1511379391-988-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1511379391-988-5-git-send-email-rppt@linux.vnet.ibm.com>
 <20171123080103.GA490@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123080103.GA490@kroah.com>
Message-Id: <20171123140725.GC2303@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Andrei Vagin <avagin@openvz.org>

On Thu, Nov 23, 2017 at 09:01:03AM +0100, Greg KH wrote:
> On Wed, Nov 22, 2017 at 09:36:31PM +0200, Mike Rapoport wrote:
> > From: Andrei Vagin <avagin@openvz.org>
> > 
> > This test checks that process_vmsplice() can splice pages from a remote
> > process and returns EFAULT, if process_vmsplice() tries to splice pages
> > by an unaccessiable address.
> > 
> > Signed-off-by: Andrei Vagin <avagin@openvz.org>
> > ---
> >  tools/testing/selftests/process_vmsplice/Makefile  |   5 +
> >  .../process_vmsplice/process_vmsplice_test.c       | 188 +++++++++++++++++++++
> >  2 files changed, 193 insertions(+)
> >  create mode 100644 tools/testing/selftests/process_vmsplice/Makefile
> >  create mode 100644 tools/testing/selftests/process_vmsplice/process_vmsplice_test.c
> > 

[ ... ]

> 
> Shouldn't you check to see if the syscall is even present?  You should
> not error if it is not, as this test will then "fail" on kernels/arches
> without the syscall enabled, which isn't the nicest.

Sure, will fix.

> thanks,
> 
> greg k-h
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
