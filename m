Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id D42629003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 11:30:24 -0400 (EDT)
Received: by ykax123 with SMTP id x123so169028982yka.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:30:24 -0700 (PDT)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id x134si16879835ywx.116.2015.07.21.08.30.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 08:30:24 -0700 (PDT)
Received: by ykfw194 with SMTP id w194so88419995ykf.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:30:23 -0700 (PDT)
Date: Tue, 21 Jul 2015 11:30:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] percpu: add macro PCPU_CHUNK_AREA_IN_USE
Message-ID: <20150721153019.GH15934@mtj.duckdns.org>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-3-git-send-email-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437404130-5188-3-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 20, 2015 at 10:55:30PM +0800, Baoquan He wrote:
> chunk->map[] contains <offset|in-use flag> of each area. Now add a
> new macro PCPU_CHUNK_AREA_IN_USE and use it as the in-use flag to
> replace all magic number '1'.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

idk, maybe.  Can you at least go for something shorter?  PCPU_MAP_BUSY
or whatever?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
