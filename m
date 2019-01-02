Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 991938E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 08:09:38 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id y2so23835012plr.8
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 05:09:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x66si51939770pfk.73.2019.01.02.05.09.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 05:09:37 -0800 (PST)
Date: Wed, 2 Jan 2019 05:09:32 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20190102130932.GH6310@bombadil.infradead.org>
References: <20181231134223.20765-1-willy@infradead.org>
 <87y385awg6.fsf@linux.ibm.com>
 <20190101063031.GD6310@bombadil.infradead.org>
 <87lg447knf.fsf@linux.ibm.com>
 <20190102031414.GG6310@bombadil.infradead.org>
 <0952D432-F520-4830-A1DE-479DFAD283E7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0952D432-F520-4830-A1DE-479DFAD283E7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, Jan 02, 2019 at 04:46:27AM -0700, William Kucharski wrote:
> It's tricky, simply because if someone doesn't know the size of their
> current page, they would generally want to know what size the current
> page is mapped as, based upon what is currently extant within that address
> space.

I'm not sure I agree with that.  It's going to depend on exactly what this
code is doing; I can definitely see there being places in the VM where we
care about how this page is currently mapped, but I think those places
are probably using the wrong interface (get_user_pages()) and should
really be using an interface which doesn't exist yet (get_user_sg()).
