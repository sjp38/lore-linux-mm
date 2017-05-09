Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2D1E6B03E9
	for <linux-mm@kvack.org>; Tue,  9 May 2017 04:58:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u12so36451136pgo.4
        for <linux-mm@kvack.org>; Tue, 09 May 2017 01:58:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l191si2119686pge.251.2017.05.09.01.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 01:58:27 -0700 (PDT)
Date: Tue, 9 May 2017 01:58:25 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
Message-ID: <20170509085825.GB32555@infradead.org>
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
 <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
 <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
 <48a544c4-61b3-acaf-0386-649f073602b6@intel.com>
 <476ea1b6-36d1-bc86-fa99-b727e3c2650d@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <476ea1b6-36d1-bc86-fa99-b727e3c2650d@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "prakash.sangappa" <prakash.sangappa@oracle.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 08, 2017 at 03:12:42PM -0700, prakash.sangappa wrote:
> Regarding #3 as a general feature, do we want to
> consider this and the complexity associated with the
> implementation?

We have to.  Given that no one has exclusive access to hugetlbfs
a mount option is fundamentally the wrong interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
