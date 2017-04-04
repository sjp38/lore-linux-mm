Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 98D1D6B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 03:46:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q19so27369612wra.6
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 00:46:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a16si2903210wme.143.2017.04.04.00.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 00:46:21 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v347i0Z7091085
	for <linux-mm@kvack.org>; Tue, 4 Apr 2017 03:46:19 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29m1yp6wj3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Apr 2017 03:46:19 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 4 Apr 2017 08:46:17 +0100
Date: Tue, 4 Apr 2017 10:46:13 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH for 4.11] userfaultfd: report actual registered features
 in fdinfo
References: <1491140181-22121-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170403143523.GC5107@redhat.com>
 <20170403151024.GA14802@rapoport-lnx>
 <20170403163034.GD5107@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403163034.GD5107@redhat.com>
Message-Id: <20170404074612.GA6082@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org

Hello Andrea,

On Mon, Apr 03, 2017 at 06:30:34PM +0200, Andrea Arcangeli wrote:
> Hello Mike,
> 
> On Mon, Apr 03, 2017 at 06:10:24PM +0300, Mike Rapoport wrote:
> > Actually, I've found these details in /proc useful when I was experimenting
> > with checkpoint-restore of an application that uses userfaultfd. With
> > interface in /proc/<pid>/ we know exactly which process use userfaultfd and
> > can act appropriately.
> 
> You've to be somewhat serialized by other means though, because
> "exactly" has a limit with fdinfo. For example by the time read()
> returns, the uffd may have been closed already by the app (just the
> uffd isn't ->release()d yet as the last fput has yet to run, the
> fdinfo runs the last fput in such case). As long as you can cope with
> this and you've a stable fdinfo it's ok.
> 

Well, by the time CRIU checkpoints open file descriptors, the process is
already stopped, hence we are not racing with anything here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
