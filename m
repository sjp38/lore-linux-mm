Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 412FAC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A0CA20857
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A0CA20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A13F86B0006; Tue, 26 Mar 2019 05:02:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C2D66B0007; Tue, 26 Mar 2019 05:02:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B47C6B0008; Tue, 26 Mar 2019 05:02:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72F5A6B0006
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:02:38 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id h51so12863336qte.22
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:02:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=dx6oo5wV0mZ/qHXm03CYEmXZ8mHzMNlZbbjH4MUUUQ4=;
        b=m0Ik0wF7WhIsrZ7T5NyWF2SNxi3+B3gA5I7L8cuhuRedh6PY34iTWVl8lJosV9iqOX
         H31VXhRu6odXTQTBrcpdoBScTGkBn3BFs2XS/142xWGu7UXLWXGyyy+GtQqMoQyySXrq
         LTj8PFY5W89sSs79xS2xA8Rx0NWxACRK3USnKAwyIZJxQXPxuMIXQk0wNt1BGPxipVVz
         5RpCSVIRuSSIQ7Na5ecyX/MDFCNzkoyUruLryF5sF+LtnsvZn1mOlXUsXy49zemDx853
         pCeaRVce7YP+1ttjlgc405dkFeXHNjljD1thPDzJ+RT3tSA2wSVaKMuyvDfcRguXYY0A
         wWYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX+cWBNSMoO4QOM5+ouJ4Er4bGXMruRm7nKi++81UdQUihz2X/K
	l83pN6xvycmiRwfo8dA/G5qhjAHtLmXIsBw3//V4VM5uIyJbLYzw9wNcb12ASfWQZQ8dNBTonxj
	z4sy/S3w5ypNBIYHeaMi/qTMmP0yXfxjAbUfxmZg4Sby1YPcHGZsJHOUswyiOfVreAA==
X-Received: by 2002:ac8:3f26:: with SMTP id c35mr23866296qtk.252.1553590958181;
        Tue, 26 Mar 2019 02:02:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjcJ/+2N96wEYHk8rHmHN6SXf/S0+1SBSuR1Rj5My4WQio1zxITEJsKp5q2RviXSo3d0NN
X-Received: by 2002:ac8:3f26:: with SMTP id c35mr23866240qtk.252.1553590957238;
        Tue, 26 Mar 2019 02:02:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553590957; cv=none;
        d=google.com; s=arc-20160816;
        b=mRegTDkmbutvwogRxSKFxkWNmDfxaQm6OUM09wrsCebm45eJdZ+23yiuRurQwQGSem
         2SKWzQGo+L92nVbYfxh2eNlxe5sWPGup0hl8miAJNklzZac4a0URPX7JxPvo8KkmTH0V
         S5wQII056umhxXuqRL2bccwjunuksg1phCalBEu4zyChBvmPa3sq3LrFuOBnLGEhBWTb
         ijFBjTLPGnD4x735/2/yFYzE2ofCDVB6ZyVWuJW5b34bpRr6H5wbN2a5s8Fd6+SAwq7y
         +J0aITmAZ9gjoV3ovhIfZg/GefTpy6jpXBePaGOl0gx5wBr8NFmZyRoowQ5rPetJY/uo
         S+YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=dx6oo5wV0mZ/qHXm03CYEmXZ8mHzMNlZbbjH4MUUUQ4=;
        b=D/RWyDG3g8dfCeK10asQXRJmg9ZyGo9jZ2OyRJ0mKE2SQYBlOj7QoRzTUwIv/RFi5J
         woWzn49Fj0mw3HWytptaafWe2vSxu0JSDfYMzN3xjJ00icJcwJkUBgS6h8fuqEzdDkOU
         wG3oUCQLN8j1wuVyzZMZ8O1uBkX9trD4A7Qjmhd60bo/vxefxPe12BJu3oKUash3j/qw
         SXJmQ8vzO7pbkg2ZRRGKla47GpTg5GwXeT+iZ2fwPeofbqeeJ1EjViJEfmS2LCtBPGw0
         Y2CVExYBKFkq2lvtXqU2iwPGW2aK5trFY7WL0wo12WjbtlJzJL7LlNip3fbb6T0P51xI
         rkew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r7si2126761qtj.61.2019.03.26.02.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:02:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B99EB31688F6;
	Tue, 26 Mar 2019 09:02:34 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 85EE780A3F;
	Tue, 26 Mar 2019 09:02:30 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	rppt@linux.ibm.com,
	osalvador@suse.de,
	willy@infradead.org,
	william.kucharski@oracle.com,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH v2 0/4] Clean up comments and codes in sparse_add_one_section()
Date: Tue, 26 Mar 2019 17:02:23 +0800
Message-Id: <20190326090227.3059-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 26 Mar 2019 09:02:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is v2 post. V1 is here:
http://lkml.kernel.org/r/20190320073540.12866-1-bhe@redhat.com

This patchset includes 4 patches. The first three patches are around
sparse_add_one_section(). The last one is a simple clean up patch when
review codes in hotplug path, carry it in this patchset.

Baoquan He (4):
  mm/sparse: Clean up the obsolete code comment
  mm/sparse: Optimize sparse_add_one_section()
  mm/sparse: Rename function related to section memmap allocation/free
  drivers/base/memory.c: Rename the misleading parameter

 drivers/base/memory.c |  6 ++---
 mm/sparse.c           | 58 ++++++++++++++++++++++---------------------
 2 files changed, 33 insertions(+), 31 deletions(-)

-- 
2.17.2

