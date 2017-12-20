Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 573476B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 19:56:54 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id a87so6505663ioj.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 16:56:54 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id g64si2094251ite.49.2017.12.19.16.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 16:56:53 -0800 (PST)
Date: Tue, 19 Dec 2017 18:56:51 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
In-Reply-To: <b38f36d7-be4f-8cc4-208e-f0778077a063@oracle.com>
Message-ID: <alpine.DEB.2.20.1712191855060.24885@nuc-kabylake>
References: <rao.shoaib@oracle.com> <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com> <alpine.DEB.2.20.1712191332090.7876@nuc-kabylake> <b38f36d7-be4f-8cc4-208e-f0778077a063@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

On Tue, 19 Dec 2017, Rao Shoaib wrote:

> > > mm/slab_common.c
> > It would be great to have separate patches so that we can review it
> > properly:
> >
> > 1. Move the code into slab_common.c
> > 2. The actual code changes to the kfree rcu mechanism
> > 3. The whitespace changes

> I can certainly break down the patch and submit smaller patches as you have
> suggested.
>
> BTW -- This is my first ever patch to Linux, so I am still learning the
> etiquette.

You are doing great. Keep at improving the patches and we will get your
changes into the kernel source. If you want to sent your first patchset
then a tool like "quilt" or "git" might be helpful.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
