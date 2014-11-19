Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9A86A6B0071
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 17:42:03 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id x19so1610132ier.27
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 14:42:03 -0800 (PST)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id x11si447596iod.19.2014.11.19.14.42.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 14:42:02 -0800 (PST)
Received: by mail-ie0-f176.google.com with SMTP id ar1so1603475iec.21
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 14:42:02 -0800 (PST)
Date: Wed, 19 Nov 2014 14:42:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] hugetlb: alloc_bootmem_huge_page(): use
 IS_ALIGNED()
In-Reply-To: <1415831593-9020-3-git-send-email-lcapitulino@redhat.com>
Message-ID: <alpine.DEB.2.10.1411191441450.24691@chino.kir.corp.google.com>
References: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com> <1415831593-9020-3-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, davidlohr@hp.com

On Wed, 12 Nov 2014, Luiz Capitulino wrote:

> No reason to duplicate the code of an existing macro.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
