Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id CE7F96B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 23:32:32 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id h15so8138026igd.8
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 20:32:32 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id h12si2773274ici.1.2014.12.16.20.32.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 20:32:31 -0800 (PST)
Received: by mail-ig0-f181.google.com with SMTP id l13so8927129iga.8
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 20:32:31 -0800 (PST)
Message-ID: <5491075B.9080609@gmail.com>
Date: Tue, 16 Dec 2014 23:32:27 -0500
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Question about Old  Fix Me comment in mempool.c
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, mpatocka@redhat.com, sebott@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Greetings Andrew and other maintainers,
I am wondering why the below comment is even in mempool.c and this has not been changed to a call to io_schedule as the kernel version is stupidly old and this should be fixed by now and the issues with DM would have been removed by now. 
/*
         * FIXME: this should be io_schedule().  The timeout is there as a
         * workaround for some DM problems in 2.6.18.
        */

Sorry for the stupid question but I like to double check with the maintainers before I sent in a patch for things like this to see if I am missing anything:).

Thanks for Your Time,
Nick 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
