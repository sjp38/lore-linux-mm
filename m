Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2EC5C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B523821841
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:03:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="L/gMHBnb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B523821841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DA116B0003; Mon,  5 Aug 2019 02:03:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48AA86B0005; Mon,  5 Aug 2019 02:03:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A1156B0006; Mon,  5 Aug 2019 02:03:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 049856B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 02:03:35 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so45564148pla.7
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 23:03:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :in-reply-to:message-id:mime-version:content-transfer-encoding;
        bh=o6EIZmq97tjek0fEBjCTF4xmiFpfjCNDQL//iLis+mU=;
        b=bjWhBg0XlOw22frdXIp1sQc0CELYZ+osOK2bwyaxqbiwX8+N+7ox1+0RKmHKdjvJvl
         FRdyamfHY2dmnMJujdDfgKV4ngU5/VexLhkk1Db9/SY3hNC3zcjMH+ebpsdRpc1W9bEa
         tn//osTdM9KYeob5IhQbSq4KSks50piffh62qGyKW44T03zDvGgbbiYJB3LGbInHw6Xl
         Kyf6XyDGCP42iZi3EuPRXyl/OUyNepSgY0X3ccJRKdJAX6g2tBVM0OSezm3wTAXDBq82
         FpUzDXpDM/Ha4l6nsdMLLn/lWOu2jivvRIWvqoq1qGeWgkpG1vJgDEIJZRO/MgYmfI5U
         sFrg==
X-Gm-Message-State: APjAAAXGcp4t7y4ma8vAi6AtVNM/j5t9WhXXUhuLDR/DO95nclpVKgHL
	zchefLoK6ZOvqZuxFdWT7EQYq/MVPJzR3633G6J71Y19ire1HmjX6leUaQkUVnp3WqqnV0hLUKO
	wHL75fFR/SJFi/DPRKrBPZZON2l6/29QMsncAcjaxdFT9Joy1AIVIYlFafuhmWyetIw==
X-Received: by 2002:a17:90a:cb81:: with SMTP id a1mr16061140pju.81.1564985014641;
        Sun, 04 Aug 2019 23:03:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxms+ou3wpS5nOO0wtIwo9hpQHNPkFdGXmqU8dv1//cmyeG/fNstv7NCCRA2D0HXEhIvM4v
X-Received: by 2002:a17:90a:cb81:: with SMTP id a1mr16061084pju.81.1564985013788;
        Sun, 04 Aug 2019 23:03:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564985013; cv=none;
        d=google.com; s=arc-20160816;
        b=LnB8Yku71qm9JOOOkiGxuca5uS1X5lTX55O0yF2SwKzpxg+bF76j45Td3JdzkIJWcv
         Y9gaOfUwNIA2n0pwt75Upi5L+3MHmdMM65FLw8zcnACzEJ3dpZ6d86Tb5AWKjYulqKw0
         qnVhERK87L2tUkIMo4JeGYw+6s+TPbDODChlRjkr3FSGTzuJt0xLbQOVscCINP7v8x+/
         5AE8wiRe7kxpdiMQAjV5KxAgojqmaiFPnQd2Qbfp7pGBUwxUHud3mh9VwjVCdPgo9ILW
         Fied9Y6y3mvbmM8meFmF/OtNGgQPI8x4nQ0ypKPc4TAJqKn45NfFaBYqYR+Yh52WoO0O
         /NJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:in-reply-to:date
         :from:cc:to:subject:dkim-signature;
        bh=o6EIZmq97tjek0fEBjCTF4xmiFpfjCNDQL//iLis+mU=;
        b=cl4YgN9a8s1RoiHFHcnj0bG+lHWXq/rHAG6H32Giye1SrJbAYuyv4NtMcVCbEewcJ6
         jKgQ56U9ipggoY1T5NnqxAZyIs5CBKLs2+C+7QOxcdH6KNFbKG8F+LJW3+zArfCIPQ7u
         nRCm/2mMFSOEU5U8FSjSurs6JJinfwuDLqBmbGsCkovTmZ2KZtmVWSGmWhP3AHmJUDqA
         EWqi10lidRrrbrhYAjKytROXVUUu1WPB3bwK1Ln+p84BNYnrFdVeikb69LINTFXp7nY9
         27bLDM6Pep6RS/+JG1oZ+NvSFKSn3rY028/wwq6t//E9FfeoCKpC8egnJBje9PTlx44L
         cFbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="L/gMHBnb";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o70si41395754pgo.280.2019.08.04.23.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 23:03:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="L/gMHBnb";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 02FDD2182B;
	Mon,  5 Aug 2019 06:03:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564985013;
	bh=Gek0nSOBXV/zkrQ+QvKwPzbCExQoQbuDXLX3kboI1Bo=;
	h=Subject:To:Cc:From:Date:In-Reply-To:From;
	b=L/gMHBnbPo3u/VRPJtDqRBMvnGq75kgxg7oPVTsPMBjboQSxqUaqTqtjMyCeY713m
	 6nTB4vxDemiXrk5qYz1azFO9xzT5XVY9ibCCxeAdeEQKzp3p/okzjjJWdZJSuMvsvW
	 cKlGpJ++upQjp3z3AggtCWoRqyexith3+pjQfLeI=
Subject: Patch "infiniband: fix race condition between infiniband mlx4, mlx5  driver and core dumping" has been added to the 4.9-stable tree
To: aarcange@redhat.com,akaher@vmware.com,akpm@linux-foundation.org,amakhalov@vmware.com,arve@android.com,bvikas@vmware.com,devel@driverdev.osuosl.org,dledford@redhat.com,gregkh@linuxfoundation.org,hal.rosenstock@gmail.com,jannh@google.com,jgg@mellanox.com,jglisse@redhat.com,leonro@mellanox.com,linux-mm@kvack.org,matanb@mellanox.com,mhocko@suse.com,mike.kravetz@oracle.com,oleg@redhat.com,peterx@redhat.com,riandrews@android.com,rppt@linux.ibm.com,sean.hefty@intel.com,srinidhir@vmware.com,srivatsa@csail.mit.edu,srivatsab@vmware.com,torvalds@linux-foundation.org,viro@zeniv.linux.org.uk,vsirnapalli@vmware.com,yishaih@mellanox.com
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Mon, 05 Aug 2019 08:03:20 +0200
In-Reply-To: <1564891168-30016-2-git-send-email-akaher@vmware.com>
Message-ID: <156498500091241@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
X-stable: commit
X-Patchwork-Hint: ignore 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This is a note to let you know that I've just added the patch titled

    infiniband: fix race condition between infiniband mlx4, mlx5  driver and core dumping

to the 4.9-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     infiniband-fix-race-condition-between-infiniband-mlx4-mlx5-driver-and-core-dumping.patch
and it can be found in the queue-4.9 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


From akaher@vmware.com  Mon Aug  5 08:01:12 2019
From: Ajay Kaher <akaher@vmware.com>
Date: Sun, 4 Aug 2019 09:29:26 +0530
Subject: infiniband: fix race condition between infiniband mlx4, mlx5  driver and core dumping
To: <aarcange@redhat.com>, <jannh@google.com>, <oleg@redhat.com>, <peterx@redhat.com>, <rppt@linux.ibm.com>, <jgg@mellanox.com>, <mhocko@suse.com>
Cc: srinidhir@vmware.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, amakhalov@vmware.com, sean.hefty@intel.com, srivatsa@csail.mit.edu, srivatsab@vmware.com, devel@driverdev.osuosl.org, linux-rdma@vger.kernel.org, bvikas@vmware.com, dledford@redhat.com, akaher@vmware.com, riandrews@android.com, hal.rosenstock@gmail.com, vsirnapalli@vmware.com, leonro@mellanox.com, jglisse@redhat.com, viro@zeniv.linux.org.uk, gregkh@linuxfoundation.org, yishaih@mellanox.com, matanb@mellanox.com, stable@vger.kernel.org, arve@android.com, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mike.kravetz@oracle.com
Message-ID: <1564891168-30016-2-git-send-email-akaher@vmware.com>

From: Ajay Kaher <akaher@vmware.com>

This patch is the extension of following upstream commit to fix
the race condition between get_task_mm() and core dumping
for IB->mlx4 and IB->mlx5 drivers:

commit 04f5866e41fb ("coredump: fix race condition between
mmget_not_zero()/get_task_mm() and core dumping")'

Thanks to Jason for pointing this.

Signed-off-by: Ajay Kaher <akaher@vmware.com>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/infiniband/hw/mlx4/main.c |    4 +++-
 drivers/infiniband/hw/mlx5/main.c |    3 +++
 2 files changed, 6 insertions(+), 1 deletion(-)

--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1172,6 +1172,8 @@ static void mlx4_ib_disassociate_ucontex
 	 * mlx4_ib_vma_close().
 	 */
 	down_write(&owning_mm->mmap_sem);
+	if (!mmget_still_valid(owning_mm))
+		goto skip_mm;
 	for (i = 0; i < HW_BAR_COUNT; i++) {
 		vma = context->hw_bar_info[i].vma;
 		if (!vma)
@@ -1190,7 +1192,7 @@ static void mlx4_ib_disassociate_ucontex
 		/* context going to be destroyed, should not access ops any more */
 		context->hw_bar_info[i].vma->vm_ops = NULL;
 	}
-
+skip_mm:
 	up_write(&owning_mm->mmap_sem);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1307,6 +1307,8 @@ static void mlx5_ib_disassociate_ucontex
 	 * mlx5_ib_vma_close.
 	 */
 	down_write(&owning_mm->mmap_sem);
+	if (!mmget_still_valid(owning_mm))
+		goto skip_mm;
 	list_for_each_entry_safe(vma_private, n, &context->vma_private_list,
 				 list) {
 		vma = vma_private->vma;
@@ -1321,6 +1323,7 @@ static void mlx5_ib_disassociate_ucontex
 		list_del(&vma_private->list);
 		kfree(vma_private);
 	}
+skip_mm:
 	up_write(&owning_mm->mmap_sem);
 	mmput(owning_mm);
 	put_task_struct(owning_process);


Patches currently in stable-queue which might be from akaher@vmware.com are

queue-4.9/infiniband-fix-race-condition-between-infiniband-mlx4-mlx5-driver-and-core-dumping.patch
queue-4.9/coredump-fix-race-condition-between-collapse_huge_page-and-core-dumping.patch
queue-4.9/coredump-fix-race-condition-between-mmget_not_zero-get_task_mm-and-core-dumping.patch

