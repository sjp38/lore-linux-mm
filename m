Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id B37366B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 11:33:22 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id w5so4555997qac.20
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 08:33:22 -0800 (PST)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTP id u5si50474949qed.99.2013.12.02.08.33.21
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 08:33:21 -0800 (PST)
Date: Mon, 2 Dec 2013 16:33:20 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: netfilter: active obj WARN when cleaning up
In-Reply-To: <20131127233415.GB19270@kroah.com>
Message-ID: <00000142b4282aaf-913f5e4c-314c-4351-9d24-615e66928157-000000@email.amazonses.com>
References: <522B25B5.6000808@oracle.com> <5294F27D.4000108@oracle.com> <20131126230709.GA10948@localhost> <alpine.DEB.2.02.1311271106090.30673@ionos.tec.linutronix.de> <20131127113939.GL16735@n2100.arm.linux.org.uk> <alpine.DEB.2.02.1311271409280.30673@ionos.tec.linutronix.de>
 <20131127133231.GO16735@n2100.arm.linux.org.uk> <20131127134015.GA6011@n2100.arm.linux.org.uk> <alpine.DEB.2.02.1311271443580.30673@ionos.tec.linutronix.de> <20131127233415.GB19270@kroah.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 27 Nov 2013, Greg KH wrote:

> Just make the kobject "dynamic" instead of embedded in struct kmem_cache
> and all will be fine.  I can't believe this code has been broken for
> this long.

The slub code is was designed to use an embedded structure since we
only get the kobj  pointer passed to us from sysfs. If kobj is not
embedded then how can we get from the sysfs object to the kmem_cache
structure from the sysfs callbacks? Sysfs was designed to have embedded
objects as far as I can recall.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
