Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id AF54D6B0037
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 10:00:51 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so7329253qae.19
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 07:00:51 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id r7si13286953qan.107.2014.06.16.07.00.50
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 07:00:51 -0700 (PDT)
Date: Mon, 16 Jun 2014 09:00:36 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slub: correct return errno on slab_sysfs_init failure
In-Reply-To: <539BFDBA.8000806@oracle.com>
Message-ID: <alpine.DEB.2.11.1406160859360.9480@gentwo.org>
References: <5399A360.3060309@oracle.com> <alpine.DEB.2.10.1406131050430.913@gentwo.org> <539BFDBA.8000806@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, penberg@kernel.org, mpm@selenic.com

On Sat, 14 Jun 2014, Jeff Liu wrote:

> Thanks for your clarification and sorry for the noise.

Dont be worried. I am not sure anymore that this was such a wise move.
Maybe get kset_create_and_add to return an error code instead and return
that instead of -ENOSYS?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
