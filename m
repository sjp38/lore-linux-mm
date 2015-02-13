Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 517876B0098
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 18:38:03 -0500 (EST)
Received: by iecrp18 with SMTP id rp18so7812591iec.9
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 15:38:03 -0800 (PST)
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com. [209.85.223.181])
        by mx.google.com with ESMTPS id dx5si7799289icb.97.2015.02.13.15.38.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Feb 2015 15:38:02 -0800 (PST)
Received: by iecar1 with SMTP id ar1so23331280iec.0
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 15:38:02 -0800 (PST)
Date: Fri, 13 Feb 2015 15:38:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm: slub: Add SLAB_DEBUG_CRASH option
In-Reply-To: <1423865980-10417-3-git-send-email-chris.j.arges@canonical.com>
Message-ID: <alpine.DEB.2.10.1502131537430.25326@chino.kir.corp.google.com>
References: <1423865980-10417-1-git-send-email-chris.j.arges@canonical.com> <1423865980-10417-3-git-send-email-chris.j.arges@canonical.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris J Arges <chris.j.arges@canonical.com>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Fri, 13 Feb 2015, Chris J Arges wrote:

> This option crashes the kernel whenever corruption is initially detected. This
> is useful when trying to use crash dump analysis to determine where memory was
> corrupted.
> 
> To enable this option use slub_debug=C.
> 

Why isn't this done in other debugging functions such as 
free_debug_processing()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
