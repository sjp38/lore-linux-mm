Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id DA65A6B0037
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 01:01:43 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hi2so5240031wib.10
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 22:01:43 -0700 (PDT)
Received: from mtaout24.012.net.il (mtaout24.012.net.il. [80.179.55.180])
        by mx.google.com with ESMTP id p4si20883799wib.92.2014.08.11.22.01.42
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 22:01:42 -0700 (PDT)
Received: from conversion-daemon.mtaout24.012.net.il by mtaout24.012.net.il (HyperSendmail v2007.08) id <0NA600700G77ZJ00@mtaout24.012.net.il> for linux-mm@kvack.org; Tue, 12 Aug 2014 07:57:23 +0300 (IDT)
Date: Tue, 12 Aug 2014 08:01:41 +0300
From: Oren Twaig <oren@scalemp.com>
Subject: x86: vmalloc and THP
Message-id: <53E99FB5.1020506@scalemp.com>
MIME-version: 1.0
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: "Shai Fultheim (Shai@ScaleMP.com)" <Shai@scalemp.com>

Hello,

Does memory allocated using vmalloc() will be mapped using huge pages 
either directly or later by THP ?

If not, is there any fast way to change this behavior ? Maybe by 
changing the granularity/alignment of such allocations to allow such 
mapping ?

Thanks,
Oren Twaig.

---
This email is free from viruses and malware because avast! Antivirus protection is active.
http://www.avast.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
