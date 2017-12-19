Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEE26B025F
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 14:33:58 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id a3so2899114itg.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:33:58 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id l16si1717806iti.23.2017.12.19.11.33.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 11:33:57 -0800 (PST)
Date: Tue, 19 Dec 2017 13:33:56 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
In-Reply-To: <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
Message-ID: <alpine.DEB.2.20.1712191332090.7876@nuc-kabylake>
References: <rao.shoaib@oracle.com> <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

On Tue, 19 Dec 2017, rao.shoaib@oracle.com wrote:

> This patch updates kfree_rcu to use new bulk memory free functions as they
> are more efficient. It also moves kfree_call_rcu() out of rcu related code to
> mm/slab_common.c

It would be great to have separate patches so that we can review it
properly:

1. Move the code into slab_common.c
2. The actual code changes to the kfree rcu mechanism
3. The whitespace changes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
