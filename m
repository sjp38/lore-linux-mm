Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 327086B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 01:17:31 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so6640901pbc.41
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 22:17:30 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id ez5si19255174pab.106.2014.02.02.22.17.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 02 Feb 2014 22:17:30 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id z10so6429446pdj.5
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 22:17:29 -0800 (PST)
Date: Sun, 2 Feb 2014 22:17:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH TRIVIAL] mm: vmscan: shrink_slab: rename max_pass ->
 freeable
In-Reply-To: <1391361090-526-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.02.1402022217100.10847@chino.kir.corp.google.com>
References: <1391361090-526-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 2 Feb 2014, Vladimir Davydov wrote:

> The name `max_pass' is misleading, because this variable actually keeps
> the estimate number of freeable objects, not the maximal number of
> objects we can scan in this pass, which can be twice that. Rename it to
> reflect its actual meaning.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
