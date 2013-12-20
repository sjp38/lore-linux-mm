Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF9866B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 21:41:52 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id 6so986987bkj.24
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 18:41:52 -0800 (PST)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id ow10si2054869bkb.116.2013.12.19.18.41.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 18:41:51 -0800 (PST)
Received: by mail-la0-f52.google.com with SMTP id y1so840468lam.11
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 18:41:51 -0800 (PST)
Date: Fri, 20 Dec 2013 03:41:30 +0100
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: A question aboout virtual mapping of kernel and module pages
Message-ID: <20131220024126.GA1852@hp530>
References: <CAKh5naYHUUUPnSv4skmX=+88AB-L=M4ruQti5cX=1BRxZY2JRg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <CAKh5naYHUUUPnSv4skmX=+88AB-L=M4ruQti5cX=1BRxZY2JRg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matvejchikov Ilya <matvejchikov@gmail.com>
Cc: linux-mm@kvack.org

Hi Ilya!

On Fri, Dec 20, 2013 at 12:25:13AM +0400, Matvejchikov Ilya wrote:
> I'm using VMAP function to create memory writable mapping as it suggested
> in ksplice project. Here is the implementation of map_writable function:
> ... 
> 
> This function works well when I used it to map kernel's text addresses. All
> fine and I can rewrite read-only data well via the mapping.
> 
> Now, I need to modify kernel module's text. Given the symbol address inside
> the module, I use the same method. The mapping I've got seems to be valid.
> But all my changes visible only in that mapping and not in the module!
> 
> I suppose that in case of module mapping I get something like copy-on-write
> but I can't prove it.
> 

Looks like I-D cache aliasing... Have you flushed cashes after your
modifications were done?

Vladimir

> Can anyone explain me what's happend and why I can use it for mapping
> kernel and can't for modules?
> 
> http://stackoverflow.com/questions/20658357/virtual-mapping-of-kernel-and-module-pages

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
