Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D10318E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 19:27:24 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id r9so614201pfb.13
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 16:27:24 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id a193si1804302pfa.214.2019.01.14.16.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 16:27:23 -0800 (PST)
Date: Mon, 14 Jan 2019 17:27:22 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] docs/core-api: memory-allocation: add mention of
 kmem_cache_create_userspace
Message-ID: <20190114172722.206546e5@lwn.net>
In-Reply-To: <1547466454-29457-1-git-send-email-rppt@linux.ibm.com>
References: <1547466454-29457-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 14 Jan 2019 13:47:34 +0200
Mike Rapoport <rppt@linux.ibm.com> wrote:

> Mention that when a part of a slab cache might be exported to the
> userspace, the cache should be created using kmem_cache_create_usercopy()
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Hmm...I didn't know that :)

Applied, thanks.

jon
