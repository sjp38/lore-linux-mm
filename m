Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34588800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 01:56:05 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u16so8246351pfh.7
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 22:56:05 -0800 (PST)
Received: from relay1.mentorg.com (relay1.mentorg.com. [192.94.38.131])
        by mx.google.com with ESMTPS id t14-v6si313608plm.455.2018.01.21.22.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jan 2018 22:56:03 -0800 (PST)
Received: from nat-ies.mentorg.com ([192.94.31.2] helo=svr-ies-mbx-02.mgc.mentorg.com)
	by relay1.mentorg.com with esmtps (TLSv1.2:ECDHE-RSA-AES256-SHA384:256)
	id 1edW1S-00053Y-Rq  
	for linux-mm@kvack.org; Sun, 21 Jan 2018 22:56:03 -0800
From: Balasubramani Vivekanandan <balasubramani_vivekanandan@mentor.com>
Subject: 
Date: Mon, 22 Jan 2018 12:25:45 +0530
Message-ID: <1516604146-4394-1-git-send-email-balasubramani_vivekanandan@mentor.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: balasubramani_vivekanandan@mentor.com


The start address sent to restore_bytes function is wrong. It points to
an location above the padding section. This is fixed in the attached patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
