Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D10DF6B04AC
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 19:42:49 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id 184so66134oii.1
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 16:42:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h7si539506oic.98.2018.01.03.16.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 16:42:49 -0800 (PST)
Date: Wed, 3 Jan 2018 18:42:13 -0600
From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: kernel BUG at ./include/linux/mm.h:LINE! (3)
Message-ID: <20180103184213.711b6704@lembas.zaitcev.lan>
In-Reply-To: <20180103210812.GC3228@bombadil.infradead.org>
References: <20171228160346.6406d52df0d9afe8cf7a0862@linux-foundation.org>
	<20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
	<20180103010238.1e510ac2@lembas.zaitcev.lan>
	<20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
	<20180103150419.2fefd759@lembas.zaitcev.lan>
	<20180103210812.GC3228@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-usb@vger.kernel.org, Pete Zaitcev <zaitcev@redhat.com>

On Wed, 3 Jan 2018 13:08:12 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> > +	mutex_lock(&rp->fetch_lock);
> >  	offset = vmf->pgoff << PAGE_SHIFT;
> >  	if (offset >= rp->b_size)
> > +		mutex_unlock(&rp->fetch_lock);
> >  		return VM_FAULT_SIGBUS;
> >  	chunk_idx = offset / CHUNK_SIZE;  
> 
> missing braces ... maybe you'd rather a 'goto sigbus' approach?

Thanks. What a way to return to kernel programming for me. I'm going
to test it anyway, already started to unpacking a PC, but yeah...

-- Pete

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
