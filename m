Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 218326B0038
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 11:25:37 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id c9so8210177qcz.0
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 08:25:36 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id b31si3826330qgd.47.2014.06.16.08.25.36
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 08:25:36 -0700 (PDT)
Date: Mon, 16 Jun 2014 10:25:33 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slub: correct return errno on slab_sysfs_init failure
In-Reply-To: <539F064B.8020701@oracle.com>
Message-ID: <alpine.DEB.2.11.1406161023420.20878@gentwo.org>
References: <5399A360.3060309@oracle.com> <alpine.DEB.2.10.1406131050430.913@gentwo.org> <539BFDBA.8000806@oracle.com> <alpine.DEB.2.11.1406160859360.9480@gentwo.org> <539F064B.8020701@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, penberg@kernel.org, mpm@selenic.com

On Mon, 16 Jun 2014, Jeff Liu wrote:

> >
> > Dont be worried. I am not sure anymore that this was such a wise move.
> > Maybe get kset_create_and_add to return an error code instead and return
> > that instead of -ENOSYS?
>
> Personally, I prefer to get kset_create_and_add() to return an error which
> can reflect the actual cause of the failure given that kset_register() can
> failed due to different reasons.  If so, however, looks we have to make a
> certain amount of change for the existing modules which are support sysfs
> since they all return -ENOMEM if kset_create_and_add() return NULL, maybe
> this is inherited from samples/kobject/kset-example.c...

Probably. Could you come up with patchset to clean this up? ERR_PTR() can
be used to return an error code in a pointer value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
