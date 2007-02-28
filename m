Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1HMRle-0008RO-VW
	for linux-mm@kvack.org; Wed, 28 Feb 2007 17:35:05 +0100
Received: from wl10583.wldelft.nl ([145.9.150.34])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 28 Feb 2007 17:35:02 +0100
Received: from leroy.vanlogchem by wl10583.wldelft.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 28 Feb 2007 17:35:02 +0100
From: Leroy van Logchem <leroy.vanlogchem@wldelft.nl>
Subject: Re: Problem with 2.6.20 and highmem64
Date: Wed, 28 Feb 2007 16:32:00 +0000 (UTC)
Message-ID: <loom.20070228T172824-198@post.gmane.org>
References: <639c60080702140711j1ec1b344p77133bb26f687e87@mail.gmail.com>  <639c60080702160038o516fd790n50923afcc136ea07@mail.gmail.com> <639c60080702160742h3c926640j52432d2198c6cb8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Adding linux-mm <at> kvack.org

> > > I installed it and at boot time, I had a hang just after "Freeing
> > > unused kernel memory" where INIT is supposed to start.

Me too.

> > > (I just witching highmem 4G and highmem64g).

Same here. Using Supermicro 7044 4GB ram 2.6.20.1 (32bit) kernel.
Compiled using CentOS 4.4's config with make oldconfig.

--
Leroy


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
