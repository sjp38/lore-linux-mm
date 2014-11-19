Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5772A6B0072
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 17:43:42 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id hl2so3759757igb.5
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 14:43:42 -0800 (PST)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id lo5si843402icb.35.2014.11.19.14.43.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 14:43:41 -0800 (PST)
Received: by mail-ie0-f180.google.com with SMTP id rp18so1620673iec.11
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 14:43:41 -0800 (PST)
Date: Wed, 19 Nov 2014 14:43:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] hugetlb: hugetlb_register_all_nodes(): add __init
 marker
In-Reply-To: <1415831593-9020-4-git-send-email-lcapitulino@redhat.com>
Message-ID: <alpine.DEB.2.10.1411191442580.24691@chino.kir.corp.google.com>
References: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com> <1415831593-9020-4-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, davidlohr@hp.com

On Wed, 12 Nov 2014, Luiz Capitulino wrote:

> This function is only called during initialization.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

And hugetlb_unregister_all_nodes() could be __exit.  The !CONFIG_NUMA 
versions would be better off inline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
