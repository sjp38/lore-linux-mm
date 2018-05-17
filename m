Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A49966B0500
	for <linux-mm@kvack.org>; Thu, 17 May 2018 11:41:22 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id w18-v6so2096260ioe.3
        for <linux-mm@kvack.org>; Thu, 17 May 2018 08:41:22 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d10-v6si4363990iog.23.2018.05.17.08.41.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 08:41:20 -0700 (PDT)
Date: Thu, 17 May 2018 08:40:55 -0700
From: Larry Bassel <larry.bassel@oracle.com>
Subject: Re: [RFC] mm, THP: Map read-only text segments using large THP pages
Message-ID: <20180517154055.GB6951@ubuette>
References: <5BB682E1-DD52-4AA9-83E9-DEF091E0C709@oracle.com>
 <20180517152333.GA26718@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180517152333.GA26718@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: William Kucharski <william.kucharski@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 17 May 18 08:23, Matthew Wilcox wrote:
> 
> I can't find any information on what page sizes SPARC supports.
> Maybe you could point me at a reference?  All I've managed to find is
> the architecture manuals for SPARC which believe it is not their purpose
> to mandate an MMU.
> 

Page sizes of 8K, 64K, 512K, 4M, 32M, 256M, 2G, 16G are allowed
architecturally -- some of these aren't present in some
SPARC machines. Generally 8K, 64K, 4M, 256M, 2G, 16G are
present on modern machines. 

Also note that the SPARC THP page size is 8M (so that it is
PMD aligned).

Larry
