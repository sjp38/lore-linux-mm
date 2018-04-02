Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 135FC6B0012
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 13:20:54 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id a10-v6so5245837itb.1
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 10:20:54 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id 2si545494ios.86.2018.04.02.10.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 10:20:52 -0700 (PDT)
Date: Mon, 2 Apr 2018 12:20:51 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] kfree_rcu() should use kfree_bulk() interface
In-Reply-To: <1522647064-27167-3-git-send-email-rao.shoaib@oracle.com>
Message-ID: <alpine.DEB.2.20.1804021217070.24404@nuc-kabylake>
References: <1522647064-27167-1-git-send-email-rao.shoaib@oracle.com> <1522647064-27167-3-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, joe@perches.com, willy@infradead.org, brouer@redhat.com, linux-mm@kvack.org

On Sun, 1 Apr 2018, rao.shoaib@oracle.com wrote:

> kfree_rcu() should use the new kfree_bulk() interface for freeing
> rcu structures as it is more efficient.

It would be even better if this approach could also use

	kmem_cache_free_bulk()

or

	kfree_bulk()
