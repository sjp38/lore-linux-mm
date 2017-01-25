Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDBF6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:55:26 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id j49so163058827otb.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:55:26 -0800 (PST)
Received: from mail-ot0-x243.google.com (mail-ot0-x243.google.com. [2607:f8b0:4003:c0f::243])
        by mx.google.com with ESMTPS id j11si9380291oib.203.2017.01.25.11.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 11:55:25 -0800 (PST)
Received: by mail-ot0-x243.google.com with SMTP id 65so24807824otq.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:55:25 -0800 (PST)
MIME-Version: 1.0
From: "A. Samy" <f.fallen45@gmail.com>
Date: Wed, 25 Jan 2017 21:55:25 +0200
Message-ID: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
Subject: ioremap_page_range: remapping of physical RAM ranges
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: zhongjiang@huawei.com

Hi,

Commit 3277953de2f31 un-exported ioremap_page_range(), what is an
alternative method of remapping a physical ram range...  This function
was very useful, examples here:
https://github.com/asamy/ksm/blob/master/mm.c#L38 and here:
https://github.com/asamy/ksm/blob/master/ksm.c#L410 etc...

So, you're forcing me to either reimplement it on my own (which is
merely copy-pasting the kernel function), unless you have a suggestion
on what else to use (which I could never find other)?

Thanks,

-- 
asamy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
