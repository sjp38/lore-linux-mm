Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 128326B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 02:49:11 -0400 (EDT)
Received: by obcgx8 with SMTP id gx8so55930642obc.3
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 23:49:10 -0700 (PDT)
Received: from proxy90-12.mail.163.com (proxy90-12.mail.163.com. [43.230.90.12])
        by mx.google.com with ESMTP id gb5si61898obb.87.2015.10.08.23.49.09
        for <linux-mm@kvack.org>;
        Thu, 08 Oct 2015 23:49:10 -0700 (PDT)
From: Yuzhou <yuzhou@mogujie.com>
Subject: containers: how to limit pagecache size?
Message-ID: <56176365.2010606@mogujie.com>
Date: Fri, 9 Oct 2015 14:49:09 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: svaidy@linux.vnet.ibm.com

Hi, all

How to limit and reclaim container's pagecache?

Thanks,
Zhang Haoyu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
