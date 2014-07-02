Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id DB9286B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 11:07:35 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id j5so4886887qga.9
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 08:07:35 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id y8si33812462qcq.19.2014.07.02.08.07.34
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 08:07:34 -0700 (PDT)
Date: Wed, 2 Jul 2014 10:07:31 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: mm: slub: invalid memory access in setup_object
In-Reply-To: <20140701144947.5ce3f93729759d8f38d7813a@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1407021006270.18104@gentwo.org>
References: <53AAFDF7.2010607@oracle.com> <alpine.DEB.2.11.1406251228130.29216@gentwo.org> <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com> <alpine.DEB.2.11.1407010956470.5353@gentwo.org>
 <20140701144947.5ce3f93729759d8f38d7813a@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Tue, 1 Jul 2014, Andrew Morton wrote:

> I can copy that text over and add the reported-by etc (ho hum) but I
> have a tiny feeling that this patch hasn't been rigorously tested?

The testing so far was to verify that  a kernel successfully builds with
the patch and then booted upo in a kvm instance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
