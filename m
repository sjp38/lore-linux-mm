Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9466B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 15:48:58 -0400 (EDT)
Received: by lbcao8 with SMTP id ao8so56931953lbc.3
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:48:57 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com. [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id x5si17094808lbb.5.2015.09.21.12.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 12:48:56 -0700 (PDT)
Received: by lanb10 with SMTP id b10so74628404lan.3
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:48:56 -0700 (PDT)
Date: Mon, 21 Sep 2015 22:48:54 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/2] mm: add architecture primitives for software dirty
 bit clearing
Message-ID: <20150921194854.GD3181@uranus>
References: <1442848940-22108-1-git-send-email-schwidefsky@de.ibm.com>
 <1442848940-22108-2-git-send-email-schwidefsky@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442848940-22108-2-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org

On Mon, Sep 21, 2015 at 05:22:19PM +0200, Martin Schwidefsky wrote:
> There are primitives to create and query the software dirty bits
> in a pte or pmd. But the clearing of the software dirty bits is done
> in common code with x86 specific page table functions.
> 
> Add the missing architecture primitives to clear the software dirty
> bits to allow the feature to be used on non-x86 systems, e.g. the
> s390 architecture.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

Looks good to me. Thank you, Martin!
(I cant ack s390 part 'casuse I simply not familiar
 with the architecture).

Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
