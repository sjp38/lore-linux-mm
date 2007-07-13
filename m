Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l6DMHHAN012817
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 15:17:18 -0700
Received: from an-out-0708.google.com (andd30.prod.google.com [10.100.30.30])
	by zps35.corp.google.com with ESMTP id l6DMHEcH008093
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 15:17:15 -0700
Received: by an-out-0708.google.com with SMTP id d30so150795and
        for <linux-mm@kvack.org>; Fri, 13 Jul 2007 15:17:14 -0700 (PDT)
Message-ID: <b040c32a0707131517m4cc20d3an2123e324746d3e7@mail.gmail.com>
Date: Fri, 13 Jul 2007 15:17:14 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] fix periodic superblock dirty inode flushing
In-Reply-To: <20070712120519.8a7241dd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0707112121y21d08438u8ca7f138931827b0@mail.gmail.com>
	 <20070712120519.8a7241dd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/12/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> Was this tested in combination with check_dirty_inode_list.patch,
> to make sure that the time-orderedness is being retained?

I think I tested with the debug patch.  And just to be sure, I ran the
test again with the time-order check in place.  It passed the test.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
