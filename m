Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id D9A076B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 11:52:42 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id x13so9964469qcv.5
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 08:52:42 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id p10si16736521qci.12.2014.06.17.08.52.41
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 08:52:42 -0700 (PDT)
Date: Tue, 17 Jun 2014 10:52:35 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 03/24] slub: return actual error on sysfs functions
In-Reply-To: <53A05071.2010905@oracle.com>
Message-ID: <alpine.DEB.2.11.1406171051430.20610@gentwo.org>
References: <53A05071.2010905@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 17 Jun 2014, Jeff Liu wrote:

> Return the actual error code if call kset_create_and_add() failed

This all looks fine to me aside from the patch sequencing issues mentioned
by others.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
