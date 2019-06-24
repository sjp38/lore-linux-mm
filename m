Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F828C48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:03:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E8B12063F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:03:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E8B12063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA36C6B000A; Mon, 24 Jun 2019 09:03:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2D6B8E0003; Mon, 24 Jun 2019 09:03:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCEE58E0002; Mon, 24 Jun 2019 09:03:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 96CD56B000A
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:03:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id i35so8174460pgi.18
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:03:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=5KnOnQ1dVge38wN21Dnu9VK2s6BnGATI94VXVgUauOc=;
        b=NenZW4+u/TyefGpduVYAkpRCxuF28JeJURWXcLZ6/gEczwppA61rEQepo5xfa6IsLD
         KJ1tT0JnF2KE18hjfu+NNI5sdA2xgaMb5/f0nJxgqhmEnCTUpuD7I4TAprKSZ+O2lqR8
         MobS/I0YygM86wTE8JSMBvHdN57JAWIHufA7QtjrfgTSPOm7uKsw8772OujyNlRaHkZf
         srYbqClGAsTak6dkCho6Dw1sk+YDVUyt+lAzpotrRsQ0EK4iGyGpHG8az6IvvdFeDSIV
         5RxnkxAbq9qgZrWkysL5D4vvwGWrT1la43cik5La3lYustikfHvis35tn97p0VhBgZLz
         9SNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAX2G5pOmoRTp2e7v/g3uc6dfHu4MCFk0Ras8kLwI4yee3LwLL1d
	pMlcMAUcb9q9ha4aymzIgWdxoEcVSPUqnnyPs1PpdoyeFbvMPgd8jHWkaT2+tb3Bua4Dm0t07V7
	Vor4KFF5dA/butg7082ET+GZcATALIJvVWTcUJF4wctfP4BcLM53SUO7BIZb8+ZxHKw==
X-Received: by 2002:a63:3d0f:: with SMTP id k15mr33053032pga.343.1561381413196;
        Mon, 24 Jun 2019 06:03:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIZXQdtY96XzJk3Rb/RNdKU2yv8RTv7WrVY5P24D/qq69vVHqfjeR49KrspQgaNcQsrOYK
X-Received: by 2002:a63:3d0f:: with SMTP id k15mr33052980pga.343.1561381412615;
        Mon, 24 Jun 2019 06:03:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561381412; cv=none;
        d=google.com; s=arc-20160816;
        b=uJPgNrJd/eDW/vXoGZK3wO0NrKK4jl8L4n9cb0+a7i7SRbHG4YZJVAjg0Bf+sRx1lF
         q+MiUnW4/zkLCHzOaKSo22loR3PFmKqLpQJm5sOezzY9eQwAP4ioOLws7Ps+ctqw5wsG
         wvUfdbj4FLPg0iAUtU9dx5C55Bu14uuDi/kgcm/vwziPjKsGzIPcD/+hcmgaXZlg4EMO
         P8Ii9CG1atbAhAfDJVIoragWqGC7wn4jJ4WBUdg6L2pfOCyTKrj4TklHcbokf0SFY2iz
         Y3xBaZ+qiwO1cwYi6q0KuFmUQMpe+Chn00MT5qBET31SE6VJanVw70GUtgG3MMn1Kh6o
         R2ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=5KnOnQ1dVge38wN21Dnu9VK2s6BnGATI94VXVgUauOc=;
        b=W19SHiBjYXmZFoGRxqXSBxbLXEoemwREtEIN+KQG0i9mK5RJotdrhPc0x0qPfgmwNf
         b4rGbs903q+gyWrIpouSafuJLnC+NxvY1WHYU0bk8Lq1Rjb7NuSh6uuCsAM+lCyCaiIE
         qfS5BTQMOzp0vSr/WdwHzHtQ4SO/nqPJyV9nqbODHTvjYSZvNvJgG3V4I5vSjW+4tQHr
         lxrCyaFJPXID4hlwc/NNPI5VUjAJrX1uByCcbeqPxEqj2AjNfMGc6v8v2iMfOeL2CQBJ
         IkgjyEhrrAqI4Bd9VG10zep9ZDT2esRg4SO6byMbNF7QovkXNT27wcriRHiRNybDJyRD
         Bgjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id h2si10829366plh.380.2019.06.24.06.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Jun 2019 06:03:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Mon, 24 Jun 2019 06:03:17 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 7BFB44141B;
	Mon, 24 Jun 2019 06:03:25 -0700 (PDT)
From: Ajay Kaher <akaher@vmware.com>
To: <aarcange@redhat.com>, <jannh@google.com>, <oleg@redhat.com>,
	<peterx@redhat.com>, <rppt@linux.ibm.com>, <jgg@mellanox.com>,
	<mhocko@suse.com>
CC: <jglisse@redhat.com>, <akpm@linux-foundation.org>,
	<mike.kravetz@oracle.com>, <viro@zeniv.linux.org.uk>,
	<riandrews@android.com>, <arve@android.com>, <yishaih@mellanox.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<matanb@mellanox.com>, <leonro@mellanox.com>,
	<linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>,
	<devel@driverdev.osuosl.org>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	<akaher@vmware.com>, <srivatsab@vmware.com>, <amakhalov@vmware.com>
Subject: [PATCH v4 0/3] [v4.9.y] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Tue, 25 Jun 2019 02:33:06 +0530
Message-ID: <1561410186-3919-4-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1561410186-3919-1-git-send-email-akaher@vmware.com>
References: <1561410186-3919-1-git-send-email-akaher@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: akaher@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

coredump: fix race condition between mmget_not_zero()/get_task_mm()
and core dumping

[PATCH v4 1/3]:
Backporting of commit 04f5866e41fb70690e28397487d8bd8eea7d712a upstream.

[PATCH v4 2/3]:
Extension of commit 04f5866e41fb to fix the race condition between
get_task_mm() and core dumping for IB->mlx4 and IB->mlx5 drivers.

[PATCH v4 3/3]
Backporting of commit 59ea6d06cfa9247b586a695c21f94afa7183af74 upstream.

[diff from v3]:
- added [PATCH v4 3/3]

