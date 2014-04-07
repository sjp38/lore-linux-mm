Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 35F216B0035
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 13:13:07 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so6836797pdj.20
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 10:13:06 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id ub3si8661374pac.71.2014.04.07.10.13.05
        for <linux-mm@kvack.org>;
        Mon, 07 Apr 2014 10:13:06 -0700 (PDT)
Date: Mon, 7 Apr 2014 12:13:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: slub: gpf in deactivate_slab
In-Reply-To: <53401F56.5090507@oracle.com>
Message-ID: <alpine.DEB.2.10.1404071212200.9896@nuc>
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com> <20140325165247.GA7519@dhcp22.suse.cz> <alpine.DEB.2.10.1403251205140.24534@nuc> <5331B9C8.7080106@oracle.com> <alpine.DEB.2.10.1403251308590.26471@nuc> <53321CB6.5050706@oracle.com>
 <alpine.DEB.2.10.1403261042360.2057@nuc> <53401F56.5090507@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 5 Apr 2014, Sasha Levin wrote:

> Unfortunately I've been unable to reproduce the issue to get more debug info
> out of it. However, I've hit something that seems to be somewhat similar
> to that:

Could you jsut run with "slub_debug" on the kernel command line to get us
more diagnostics? Could be memory corruption.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
