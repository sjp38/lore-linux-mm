Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 00E3C6B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 10:44:56 -0400 (EDT)
Received: by obvd1 with SMTP id d1so82868324obv.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 07:44:55 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id d9si2194559oeu.105.2015.04.01.07.44.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Apr 2015 07:44:38 -0700 (PDT)
Date: Wed, 1 Apr 2015 16:44:31 +0200
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] Documentation/memcg: update memcg/kmem status
Message-ID: <20150401164431.1e88220a@lwn.net>
In-Reply-To: <1427898636-4505-1-git-send-email-vdavydov@parallels.com>
References: <1427898636-4505-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 1 Apr 2015 17:30:36 +0300
Vladimir Davydov <vdavydov@parallels.com> wrote:

> Memcg/kmem reclaim support has been finally merged. Reflect this in the
> documentation.

So the text you've removed says not to select kmem support "unless for
development purposes."  Do we now believe that this feature is ready for
use in a production setting?  If the answer is "yes," I'd be happy to
take this through the docs tree.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
