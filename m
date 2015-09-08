Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 225986B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 19:14:48 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so2684938ioi.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 16:14:48 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id oa7si8046991pdb.56.2015.09.08.16.14.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 16:14:47 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so51926014pad.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 16:14:47 -0700 (PDT)
Date: Tue, 8 Sep 2015 16:14:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in
 find_vma()
In-Reply-To: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl>
Message-ID: <alpine.DEB.2.10.1509081614320.26116@chino.kir.corp.google.com>
References: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-523733570-1441754086=:26116"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-523733570-1441754086=:26116
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 5 Sep 2015, Chen Gang wrote:

> 
> From b12fa5a9263cf4c044988e59f0071f4bcc132215 Mon Sep 17 00:00:00 2001
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Sat, 5 Sep 2015 21:49:56 +0800
> Subject: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in
>  find_vma()
> 
> Before the main looping, vma is already is NULL, so need not set it to
> NULL, again.
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>
--397176738-523733570-1441754086=:26116--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
