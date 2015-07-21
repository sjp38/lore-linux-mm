Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id F35619003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 11:33:12 -0400 (EDT)
Received: by ykax123 with SMTP id x123so169106893yka.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:33:12 -0700 (PDT)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com. [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id i8si16877928ykd.110.2015.07.21.08.33.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 08:33:12 -0700 (PDT)
Received: by ykax123 with SMTP id x123so169106399yka.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:33:11 -0700 (PDT)
Date: Tue, 21 Jul 2015 11:33:08 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] percpu: clean up of schunk->map[] assignment in
 pcpu_setup_first_chunk
Message-ID: <20150721153308.GI15934@mtj.duckdns.org>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437404130-5188-1-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 20, 2015 at 10:55:28PM +0800, Baoquan He wrote:
> The original assignment is a little redundent.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

Heh, I'm not sure this is actually better.  Anyways, applied to
percpu/for-4.3.  In general tho, I don't really think this level of
micro cleanup patches are worthwhile.  If something around it changes,
sure, take the chance and clean it up but as standalone patches these
aren't that readily justifiable.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
