Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB676B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 12:56:02 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w101so10002655wrc.18
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 09:56:02 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id a19si4626074wrh.3.2018.01.31.09.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 09:56:01 -0800 (PST)
Date: Wed, 31 Jan 2018 17:55:58 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [LSF/MM TOPIC] Killing reliance on struct page->mapping
Message-ID: <20180131175558.GA30522@ZenIV.linux.org.uk>
References: <20180130004347.GD4526@redhat.com>
 <20180131165646.GI29051@ZenIV.linux.org.uk>
 <20180131174245.GE2912@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131174245.GE2912@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed, Jan 31, 2018 at 12:42:45PM -0500, Jerome Glisse wrote:

> For block devices the idea is to use struct page and buffer_head (first one of
> a page) as a key to find mapping (struct address_space) back.

Details, please...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
