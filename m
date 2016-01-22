Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 367AA6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 20:29:01 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id 6so46895919qgy.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 17:29:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v11si4350465qkl.64.2016.01.21.17.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 17:29:00 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: [LSF/MM TOPIC] Persistent Memory Error Handling
Date: Thu, 21 Jan 2016 20:28:58 -0500
Message-ID: <x49oacee71h.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Hi,

The SNIA Non-volatile Memory Programming Technical Work Group (NVMP-TWG)
is working on more closely defining how errors are reported and
cleared for persistent memory.  I'd like to give an overview of that
work and open the floor to discussion.  This topic covers file systems,
memory management, and the block layer so would be suitable for a
plenary session.

Thanks,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
