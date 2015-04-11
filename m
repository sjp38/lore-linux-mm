Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id A3E0C6B0038
	for <linux-mm@kvack.org>; Sat, 11 Apr 2015 09:24:20 -0400 (EDT)
Received: by qkx62 with SMTP id 62so79446692qkx.0
        for <linux-mm@kvack.org>; Sat, 11 Apr 2015 06:24:20 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id t189si1103804oit.58.2015.04.11.06.24.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 11 Apr 2015 06:24:19 -0700 (PDT)
Date: Sat, 11 Apr 2015 15:24:11 +0200
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] Documentation/memcg: update memcg/kmem status
Message-ID: <20150411152411.1c5a97fd@lwn.net>
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

Applied to the docs tree with Michal's ack.

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
