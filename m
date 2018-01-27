Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 989416B0030
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 22:23:19 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id z37so3652281qtj.15
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 19:23:19 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x22si1909061qka.31.2018.01.26.19.23.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 19:23:18 -0800 (PST)
From: William Kucharski <william.kucharski@oracle.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.9\))
Subject: [PATCH v2] mm: Correct comments regarding do_fault_around() 
Message-Id: <00DD15FC-863C-479C-A433-2F8CEDB03AEE@oracle.com>
Date: Fri, 26 Jan 2018 20:23:13 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
