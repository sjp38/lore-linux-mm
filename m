Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02AEA6B03C6
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 08:53:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 34so1524706wrb.20
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 05:53:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f71si8645366wmh.127.2017.04.05.05.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 05:53:29 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v35CmksC070492
	for <linux-mm@kvack.org>; Wed, 5 Apr 2017 08:53:28 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29mytgkwf4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Apr 2017 08:53:27 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Apr 2017 13:53:26 +0100
Date: Wed, 5 Apr 2017 15:53:22 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: Heavy I/O causing slow interactivity
References: <CAGDaZ_qvb7QcWr3MaqnYOFeuqBQzTwzzOKwHXOUxa+S256uc=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_qvb7QcWr3MaqnYOFeuqBQzTwzzOKwHXOUxa+S256uc=g@mail.gmail.com>
Message-Id: <20170405125322.GB9146@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

On Mon, Apr 03, 2017 at 10:39:39AM -0700, Raymond Jennings wrote:
> I'm running gentoo and it's emerging llvm.  This I/O heavy process is
> causing slowdowns when I attempt interactive stuff, including watching
> a youtube video and accessing a chatroom.

"emerge llvm" means "build LLVM compiler suite and install it", right?
This could be quite CPU and memory intensive as well.
Depending on your hardware and options you use it just may end up eating all
the system resources...
 
> Similar latency is induced during a heavy database application.
> 
> As an end user is there anything I can do to better support
> interactive performance?
> 
> And as a potential kernel developer, is there anything I could tweak
> in the kernel source to mitigate this behavior?
> 
> I've tried SCHED_IDLE and idle class with ionice, both to no avail.
 
--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
