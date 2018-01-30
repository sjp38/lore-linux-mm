Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04E426B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 19:43:52 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id s5so6110351oib.7
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 16:43:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h131si5651050oia.404.2018.01.29.16.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 16:43:51 -0800 (PST)
Date: Mon, 29 Jan 2018 19:43:48 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: [LSF/MM TOPIC] Killing reliance on struct page->mapping
Message-ID: <20180130004347.GD4526@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

I started a patchset about $TOPIC a while ago, right now i am working on other
thing but i hope to have an RFC for $TOPIC before LSF/MM and thus would like a
slot during common track to talk about it as it impacts FS, BLOCK and MM (i am
assuming their will be common track).

Idea is that mapping (struct address_space) is available in virtualy all the
places where it is needed and that their should be no reasons to depend only on
struct page->mapping field. My patchset basicly add mapping to a bunch of vfs
callback (struct address_space_operations) where it is missing, changing call
site. Then i do an individual patch per filesystem to leverage the new argument
instead on struct page.

I am doing this for a generic page write protection mechanism which generalize
KSM to file back page. They are couple other aspect like struct page->index,
struct page->private which are addressed in similar way. The block layer is
mostly affected because on block device error it needs the page->mapping to
report I/O error.

Maybe we can kill page->mapping altogether as a result of this. However this is
not my motivation at this time.


Sorry for absence of patchset at this time but i wanted to submit the subject
before LSF/MM deadline.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
