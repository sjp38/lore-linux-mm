Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 772156B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 12:44:15 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id 9so202503489iom.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 09:44:15 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b8si36384078igx.61.2016.02.16.09.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 09:44:14 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [LSF/MM ATTEND] mm validation, hugepages
Message-ID: <56C35FE3.5010304@oracle.com>
Date: Tue, 16 Feb 2016 12:44:03 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi all,

I'd like to participate in this year's LSF/MM to continue my
work on improving the testing and validation of MM code.

While I'm currently doing work aimed at improving hugepage related
testing, it's important to understand how other parts of MM can
be easier to test and fuzz.

It'll be interesting to expose other, more untested and/or bitrotten
bits to userspace testing and fuzzing, but it's not clear which parts
are of interest, and which assumptions the existing code makes about
those bits - something we need to clarify.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
