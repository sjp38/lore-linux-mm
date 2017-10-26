Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10E526B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 21:19:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n14so1142004pfh.15
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 18:19:18 -0700 (PDT)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTP id z8si2777472pfd.425.2017.10.25.18.19.16
        for <linux-mm@kvack.org>;
        Wed, 25 Oct 2017 18:19:16 -0700 (PDT)
Subject: Re: [PATCH 2/2] scsi: megaraid: Track the page allocations for struct
 fusion_context
References: <1508925428-51660-1-git-send-email-xieyisheng1@huawei.com>
 <1508925428-51660-2-git-send-email-xieyisheng1@huawei.com>
 <yq17evjieug.fsf@oracle.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <5a4a6b21-bd94-910a-a278-265b848a50a5@huawei.com>
Date: Thu, 26 Oct 2017 09:17:29 +0800
MIME-Version: 1.0
In-Reply-To: <yq17evjieug.fsf@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: kashyap.desai@broadcom.com, sumit.saxena@broadcom.com, shivasharan.srikanteshwara@broadcom.com, jejb@linux.vnet.ibm.com, megaraidlinux.pdl@broadcom.com, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Shu Wang <shuwang@redhat.com>

Hi Martin K. Peterseni 1/4 ?

Thanks for comment!
On 2017/10/25 20:36, Martin K. Petersen wrote:
> 
> Yisheng,
> 
>> I have get many kmemleak reports just similar to commit 70c54e210ee9
>> (scsi: megaraid_sas: fix memleak in megasas_alloc_cmdlist_fusion)
>> on v4.14-rc6, however it seems have a different stroy:
> 
> Do you still see leaks reported with the megaraid driver update recently
> merged into 4.15/scsi-queue?

No, the related code have been optimized, sorry to disturb. Please ignore
this one.

Thanks
Yisheng Xie


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
