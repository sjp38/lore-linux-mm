Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 483E66B006E
	for <linux-mm@kvack.org>; Thu,  7 May 2015 10:33:48 -0400 (EDT)
Received: by qcbgy10 with SMTP id gy10so21887416qcb.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 07:33:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m46si2167922qgd.70.2015.05.07.07.33.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 07:33:47 -0700 (PDT)
Date: Thu, 7 May 2015 16:33:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] UserfaultFD: Rename uffd_api.bits into .features
Message-ID: <20150507143343.GG13098@redhat.com>
References: <5509D342.7000403@parallels.com>
 <20150421120222.GC4481@redhat.com>
 <55389261.50105@parallels.com>
 <20150427211650.GC24035@redhat.com>
 <55425A74.3020604@parallels.com>
 <20150507134236.GB13098@redhat.com>
 <554B769E.1040000@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <554B769E.1040000@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>

On Thu, May 07, 2015 at 05:28:46PM +0300, Pavel Emelyanov wrote:
> Yup, this is very close to what I did in my set -- introduced a message to
> report back to the user-space on read. But my message is more than 8+2*1 bytes,
> so we'll have one message for 0xAA API and another one for 0xAB (new) one :)

I slightly altered it to fix an issue with packet alignments so it'd
be 16bytes.

How big is your msg currently? Could we get to use the same API?

UFFDIO_REGISTER_MODE_FORK

or 

UFFDIO_REGISTER_MODE_NON_COOPERATIVE would differentiate if you want
to register for fork/mremap/dontneed events as well or only the
default (UFFD_EVENT_PAGEFAULT).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
