Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id EF6E06B0069
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 17:39:17 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id hl2so3730059igb.17
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 14:39:17 -0800 (PST)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com. [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id mp6si830999icb.39.2014.11.19.14.39.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 14:39:16 -0800 (PST)
Received: by mail-ie0-f172.google.com with SMTP id ar1so1600686iec.17
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 14:39:16 -0800 (PST)
Date: Wed, 19 Nov 2014 14:39:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] hugetlb: fix hugepages= entry in
 kernel-parameters.txt
In-Reply-To: <1415831593-9020-2-git-send-email-lcapitulino@redhat.com>
Message-ID: <alpine.DEB.2.10.1411191439030.24691@chino.kir.corp.google.com>
References: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com> <1415831593-9020-2-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, davidlohr@hp.com

On Wed, 12 Nov 2014, Luiz Capitulino wrote:

> The hugepages= entry in kernel-parameters.txt states that
> 1GB pages can only be allocated at boot time and not
> freed afterwards. This is not true since commit
> 944d9fec8d7aee, at least for x86_64.
> 
> Instead of adding arch-specifc observations to the
> hugepages= entry, this commit just drops the out of date
> information. Further information about arch-specific
> support and available features can be obtained in the
> hugetlb documentation.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
