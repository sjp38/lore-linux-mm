Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9D236B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 20:14:33 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id c184so2357065ywh.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 17:14:33 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id m5si855554ywf.598.2018.04.16.17.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Apr 2018 17:14:32 -0700 (PDT)
Date: Mon, 16 Apr 2018 20:14:22 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] dax: Change return type to vm_fault_t
Message-ID: <20180417001421.GH22870@thunk.org>
References: <20180414155059.GA18015@jordon-HP-15-Notebook-PC>
 <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Mon, Apr 16, 2018 at 09:14:48AM -0700, Dan Williams wrote:
> Ugh, so this change to vmf_insert_mixed() went upstream without fixing
> the users? This changelog is now misleading as it does not mention
> that is now an urgent standalone fix. On first read I assumed this was
> part of a wider effort for 4.18.

Why is this an urgent fix?  I thought all the return type change was
did something completely innocuous that would not cause any real
difference.

Otherwise there are a dozen plus "fixups" to change the users that
will now become urgent fixes, which I did *not* expect to be the case.
(Where two are in ext2 and ext4, and where I planned to take my time
and get them fixed in the next merge window, precisely becuase I did
not *think* they were urgent.)

    	    	 			- Ted
