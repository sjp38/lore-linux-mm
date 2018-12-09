Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9788E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 18:02:03 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so6239452pgt.11
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 15:02:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor15220397pfj.35.2018.12.09.15.02.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 15:02:02 -0800 (PST)
Date: Sun, 9 Dec 2018 15:02:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] slab: make kmem_cache_create{_usercopy} description
 proper kernel-doc
In-Reply-To: <1544130781-13443-2-git-send-email-rppt@linux.ibm.com>
Message-ID: <alpine.DEB.2.21.1812091501460.206717@chino.kir.corp.google.com>
References: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com> <1544130781-13443-2-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 6 Dec 2018, Mike Rapoport wrote:

> Add the description for kmem_cache_create, fixup the return value paragraph
> and make both kmem_cache_create and add the second '*' to the comment
> opening.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>
