Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE6FF8E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 07:52:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b17-v6so2334076pfo.20
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 04:52:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g12-v6sor301900pgr.8.2018.09.25.04.51.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 04:51:59 -0700 (PDT)
Date: Tue, 25 Sep 2018 14:51:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Disable movable allocation for TRANSHUGE pages
Message-ID: <20180925115153.z5b5ekijf5jzhzmn@kshutemo-mobl1>
References: <1537860333-28416-1-git-send-email-amhetre@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1537860333-28416-1-git-send-email-amhetre@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Mhetre <amhetre@nvidia.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com

On Tue, Sep 25, 2018 at 12:55:33PM +0530, Ashish Mhetre wrote:
> TRANSHUGE pages have no migration support.

Transparent pages have migration support since v4.14.

-- 
 Kirill A. Shutemov
