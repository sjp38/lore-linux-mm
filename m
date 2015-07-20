Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD269003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 11:35:04 -0400 (EDT)
Received: by oige126 with SMTP id e126so110959197oig.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:35:04 -0700 (PDT)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id m4si17329211icp.1.2015.07.20.08.35.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 08:35:03 -0700 (PDT)
Date: Mon, 20 Jul 2015 10:35:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] percpu: add macro PCPU_CHUNK_AREA_IN_USE
In-Reply-To: <1437404130-5188-3-git-send-email-bhe@redhat.com>
Message-ID: <alpine.DEB.2.11.1507201034210.14535@east.gentwo.org>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com> <1437404130-5188-3-git-send-email-bhe@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Jul 2015, Baoquan He wrote:

> chunk->map[] contains <offset|in-use flag> of each area. Now add a
> new macro PCPU_CHUNK_AREA_IN_USE and use it as the in-use flag to
> replace all magic number '1'.

Hmmm... This is a bitflag and the code now looks like there is some sort
of bitmask that were are using. Use bitops or something else that clearly
implies that a bit is flipped instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
