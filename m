Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E38D26B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 11:56:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e74so163774wmg.0
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 08:56:54 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id m137si43489wmb.269.2018.01.31.08.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 08:56:50 -0800 (PST)
Date: Wed, 31 Jan 2018 16:56:46 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [LSF/MM TOPIC] Killing reliance on struct page->mapping
Message-ID: <20180131165646.GI29051@ZenIV.linux.org.uk>
References: <20180130004347.GD4526@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130004347.GD4526@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Mon, Jan 29, 2018 at 07:43:48PM -0500, Jerome Glisse wrote:
> I started a patchset about $TOPIC a while ago, right now i am working on other
> thing but i hope to have an RFC for $TOPIC before LSF/MM and thus would like a
> slot during common track to talk about it as it impacts FS, BLOCK and MM (i am
> assuming their will be common track).
> 
> Idea is that mapping (struct address_space) is available in virtualy all the
> places where it is needed and that their should be no reasons to depend only on
> struct page->mapping field. My patchset basicly add mapping to a bunch of vfs
> callback (struct address_space_operations) where it is missing, changing call
> site. Then i do an individual patch per filesystem to leverage the new argument
> instead on struct page.

Oh?  What about the places like fs/coda?  Or block devices, for that matter...
You can't count upon file->f_mapping->host == file_inode(file).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
