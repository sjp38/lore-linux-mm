Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8A16B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 09:51:13 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q107so3523881qgd.19
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 06:51:13 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id 33si3184674qgh.70.2014.07.07.06.51.11
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 06:51:12 -0700 (PDT)
Date: Mon, 7 Jul 2014 08:51:08 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: mm: slub: invalid memory access in setup_object
In-Reply-To: <20140703124015.GA17431@richard>
Message-ID: <alpine.DEB.2.11.1407070850510.21323@gentwo.org>
References: <53AAFDF7.2010607@oracle.com> <alpine.DEB.2.11.1406251228130.29216@gentwo.org> <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com> <alpine.DEB.2.11.1407010956470.5353@gentwo.org> <20140702020454.GA6961@richard>
 <alpine.DEB.2.11.1407020918130.17773@gentwo.org> <20140703124015.GA17431@richard>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Thu, 3 Jul 2014, Wei Yang wrote:

> Here is my refined version, hope this is more friendly to the audience.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
