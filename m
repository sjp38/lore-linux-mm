Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id DDA286B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 10:45:02 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id k15so8936330qaq.2
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 07:45:02 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id 90si34062062qgf.28.2014.07.02.07.45.00
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 07:45:01 -0700 (PDT)
Date: Wed, 2 Jul 2014 09:44:57 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: mm: slub: invalid memory access in setup_object
In-Reply-To: <53B32D80.8000601@oracle.com>
Message-ID: <alpine.DEB.2.11.1407020935450.17773@gentwo.org>
References: <53AAFDF7.2010607@oracle.com> <alpine.DEB.2.11.1406251228130.29216@gentwo.org> <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com> <alpine.DEB.2.11.1407010956470.5353@gentwo.org> <20140701144947.5ce3f93729759d8f38d7813a@linux-foundation.org>
 <53B32D80.8000601@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Tue, 1 Jul 2014, Sasha Levin wrote:

> Is there a better way to stress test slub?

The typical way to test is by stressing the network subsystem
with small packets that require small allocations. Or do a filesystem
test that requires lots of metadata (file creations, removal, renames
etc).

But I also posted some in kernel benchmarks a while back

https://lkml.org/lkml/2009/10/13/459

Pekka had a project going to get these merged.

https://lkml.org/lkml/2009/11/29/17


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
