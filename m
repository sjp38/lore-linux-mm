Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id E523D6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 10:39:57 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id c9so2268981qcz.28
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 07:39:57 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id 60si6622390qgh.26.2014.06.19.07.39.57
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 07:39:57 -0700 (PDT)
Date: Thu, 19 Jun 2014 09:39:54 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH RESEND] slub: return correct error on slab_sysfs_init
In-Reply-To: <alpine.DEB.2.02.1406181314290.10339@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1406190939030.2785@gentwo.org>
References: <53A0EB84.7030308@oracle.com> <alpine.DEB.2.02.1406181314290.10339@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jeff Liu <jeff.liu@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, akpm@linuxfoundation.org

On Wed, 18 Jun 2014, David Rientjes wrote:

> Why?  kset_create_and_add() can fail for a few other reasons other than
> memory constraints and given that this is only done at bootstrap, it
> actually seems like a duplicate name would be a bigger concern than low on
> memory if another init call actually registered it.

Greg said that the only reason for failure would be out of memory.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
