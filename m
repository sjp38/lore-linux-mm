Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5916B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 10:23:45 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id i5so38311285ige.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 07:23:45 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id 7si3393912iow.43.2016.05.17.07.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 07:23:44 -0700 (PDT)
Date: Tue, 17 May 2016 09:23:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub.c: fix sysfs filename in comment
In-Reply-To: <1463449242-5366-1-git-send-email-lip@dtdream.com>
Message-ID: <alpine.DEB.2.20.1605170922480.10037@east.gentwo.org>
References: <1463449242-5366-1-git-send-email-lip@dtdream.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Peng <lip@dtdream.com>
Cc: penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 17 May 2016, Li Peng wrote:
> /sys/kernel/slab/xx/defrag_ratio should be remote_node_defrag_ratio.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
