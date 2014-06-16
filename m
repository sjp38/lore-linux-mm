Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1916B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 10:59:34 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so1231878pdb.30
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 07:59:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id vv7si13950898pab.124.2014.06.16.07.59.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 07:59:33 -0700 (PDT)
Message-ID: <539F064B.8020701@oracle.com>
Date: Mon, 16 Jun 2014 22:59:23 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: correct return errno on slab_sysfs_init failure
References: <5399A360.3060309@oracle.com> <alpine.DEB.2.10.1406131050430.913@gentwo.org> <539BFDBA.8000806@oracle.com> <alpine.DEB.2.11.1406160859360.9480@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1406160859360.9480@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-mm@kvack.org, penberg@kernel.org, mpm@selenic.com


On 06/16/2014 22:00 PM, Christoph Lameter wrote:
> On Sat, 14 Jun 2014, Jeff Liu wrote:
> 
>> Thanks for your clarification and sorry for the noise.
> 
> Dont be worried. I am not sure anymore that this was such a wise move.
> Maybe get kset_create_and_add to return an error code instead and return
> that instead of -ENOSYS?

Personally, I prefer to get kset_create_and_add() to return an error which
can reflect the actual cause of the failure given that kset_register() can
failed due to different reasons.  If so, however, looks we have to make a
certain amount of change for the existing modules which are support sysfs
since they all return -ENOMEM if kset_create_and_add() return NULL, maybe
this is inherited from samples/kobject/kset-example.c...


Cheers,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
