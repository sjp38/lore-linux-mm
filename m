Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97C6F6B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 08:36:52 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n61so19470099qte.3
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 05:36:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 42si2231404qkx.439.2017.10.25.05.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Oct 2017 05:36:51 -0700 (PDT)
Subject: Re: [PATCH 2/2] scsi: megaraid: Track the page allocations for struct fusion_context
From: "Martin K. Petersen" <martin.petersen@oracle.com>
References: <1508925428-51660-1-git-send-email-xieyisheng1@huawei.com>
	<1508925428-51660-2-git-send-email-xieyisheng1@huawei.com>
Date: Wed, 25 Oct 2017 08:36:39 -0400
In-Reply-To: <1508925428-51660-2-git-send-email-xieyisheng1@huawei.com>
	(Yisheng Xie's message of "Wed, 25 Oct 2017 17:57:08 +0800")
Message-ID: <yq17evjieug.fsf@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: kashyap.desai@broadcom.com, sumit.saxena@broadcom.com, shivasharan.srikanteshwara@broadcom.com, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, megaraidlinux.pdl@broadcom.com, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Shu Wang <shuwang@redhat.com>


Yisheng,

> I have get many kmemleak reports just similar to commit 70c54e210ee9
> (scsi: megaraid_sas: fix memleak in megasas_alloc_cmdlist_fusion)
> on v4.14-rc6, however it seems have a different stroy:

Do you still see leaks reported with the megaraid driver update recently
merged into 4.15/scsi-queue?

-- 
Martin K. Petersen	Oracle Linux Engineering

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
