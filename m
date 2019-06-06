Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2464CC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:46:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF292206BB
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:46:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="eoZ3O1Re"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF292206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79B966B0283; Thu,  6 Jun 2019 15:46:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74C736B0284; Thu,  6 Jun 2019 15:46:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 662826B0285; Thu,  6 Jun 2019 15:46:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47BDC6B0283
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 15:46:54 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n190so2945926qkd.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 12:46:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qajFXRwDSumJ1VBt1nbVb8YwByztvxS980sXRo7osmo=;
        b=bI/L8bxcJa0V4sJ8FVToYHobjrLE/jVBnk+FjrLjL1fXyq/g45lsQ+cBt4SFq3lOsN
         RGgKUkKLVMN0KsT18cSJU57GOOphQaWeiMlwwkVFKXoGEI9f9g7v3EVRgmSqKZ7zuIKQ
         yHTGe4bOeapm1oIxSHzu2CURz0LzC/yz+KXE13tUZ5l1CSMUylYlQqa2rudTQ9efvoQb
         KJTYwdWkFe0P3wGPkKSzACSYDSD3xhNpOtInyRgbbslQG+taSxBW3ESAL2iBWgp9UXfx
         48kfjkyw4tXS38iH0JzhAA3fx/tg/qKoIlv+ZwcKu/myGTR0avInNQ0OQFvB0EWlnb7l
         L2Qg==
X-Gm-Message-State: APjAAAWeVnDeJeOuP9VD3TvN7zWdeA6C11NmRjLsror1R8SseEfNa5HE
	71pLAF0KXWiD3xQ5id4gPfi0v5MWkKqjHTmlAN9/QwrxxfCg0fKZagjbTdnEJuPu3Bb9R/HzNz3
	b66dnEW34s6xE41I0BQQ8/BuU3GYeOBuAMF4t4oWiVYBcI65Lc4w/++nj1AguHvOYkw==
X-Received: by 2002:a37:a5c3:: with SMTP id o186mr40632436qke.108.1559850414077;
        Thu, 06 Jun 2019 12:46:54 -0700 (PDT)
X-Received: by 2002:a37:a5c3:: with SMTP id o186mr40632393qke.108.1559850413452;
        Thu, 06 Jun 2019 12:46:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559850413; cv=none;
        d=google.com; s=arc-20160816;
        b=jceMr2HU3Q40qhSu0tJxKp2BCafecFlDYiV9/q6oRsObIxtutwqFUJUIAcY1HK3RWz
         bAWeDFQmHPt1AvghRNWKWe/C3H4BJSBQPoeep6r2QMK6aoLaZyXd1hwSiDCctShVtnaO
         EPsNgEN5JE4F7YZrU0FYOTs1ra/byMhpkM5D7YB1Ws2j2fJaJ7AVT3/6OP6mQY2s9kBY
         EMLpzNUUlocwp0LyLFwqAOx1XyY2u4u5+cEk6yH04hf69Vxy4lOSizVZN3Q18gxfINV1
         +NPYukvsNV8uZpk/xdFNL4zSrnKCarFPOLHHMBjLlcPZ8TI6dNOWMZO/l8cIZ8DdOgPC
         lIZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qajFXRwDSumJ1VBt1nbVb8YwByztvxS980sXRo7osmo=;
        b=UYrkbUGUXkCn9ynozxnM5tjk1GhpZiBFrartsXOkNCscNlTUIGBwJLG8kmHj/YRfMF
         0nA6NZMoafPT5+iw02h3Bw4+jj8Fv15RxY0PQQty356GpMG2bot1YIEOtZYCk7Y5LZgo
         OMhHXbq4vklmpBktwpPFTY5ZFGDVgKGN54t9WEUTAWGbWfkwaeohsY2hv3BwwvwJQ7/w
         LbkLs8kt746P0lBXmMYyD3KLfWBx9lrJDLLTSVCim01jslm/q1Vx/9AvtWWj5/rKwO5i
         aIxsB+tOJ4zRjkk37+Tjv0H7zwIRzLxark+6UTjIsbqc/cIiQJhvRPhCW3DY+YyasKvG
         j6jQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eoZ3O1Re;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w45sor17671qvc.66.2019.06.06.12.46.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 12:46:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eoZ3O1Re;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=qajFXRwDSumJ1VBt1nbVb8YwByztvxS980sXRo7osmo=;
        b=eoZ3O1RetGytNaHJt1/lQ055Dyp4yKlZbucZb+BvUi5davTaqNwzsojRJaEX3o7YBt
         pW3kUz6Q6eZ28rLtA9Jjv3JM9Jbd8rpL+tsDn7iM2UqXOLGkn166O+4yvLdC3Kj1J1Kw
         EN/awr72rkEt7yQR+AiRXrTbLCAXuw/PReh8Jee8gULLsUma+/gjV4ptkpnFqaWY9ScQ
         pfzfEEURVPjfvQ17a2N2djx/e2F+JgvAKdq7T0ZC0+SYGMwKMi53TV6yqzPwuSf8v+9u
         LYyAO6rl9kNxn5WFf8W3yFzNwERteSui2pJz14BOr2RQ5bfl/hj47SMCT66KbVbY4Rcp
         hJzg==
X-Google-Smtp-Source: APXvYqzAxBsAbtmAf/N2gWiDpLiwySAazMdlavwrTbL7etxy94AKJa3CMpYnlx0qPyIVzWATublI1w==
X-Received: by 2002:a0c:d0b6:: with SMTP id z51mr27514879qvg.3.1559850413173;
        Thu, 06 Jun 2019 12:46:53 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id t197sm1407918qke.2.2019.06.06.12.46.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 12:46:52 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYyLc-0007zs-5h; Thu, 06 Jun 2019 16:46:52 -0300
Date: Thu, 6 Jun 2019 16:46:52 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190606194652.GI17373@ziepe.ca>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <c559c2ce-50dc-d143-5741-fe3d21d0305c@nvidia.com>
 <20190606171158.GB11374@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606171158.GB11374@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 10:11:58AM -0700, Ira Weiny wrote:

> 2) This is a bit more subtle and something I almost delayed sending these out
>    for.  Currently the implementation of a lease break actually removes the
>    lease from the file.  I did not want this to happen and I was thinking of
>    delaying this patch set to implement something which keeps the lease around
>    but I figured I should get something out for comments.  Jan has proposed
>    something along these lines and I agree with him so I'm going to ask you to
>    read my response to him about the details.
>
> 
>    Anyway so the key here is that currently an app needs the SIGIO to retake
>    the lease if they want to map the file again or in parts based on usage.
>    For example, they may only want to map some of the file for when they are
>    using it and then map another part later.  Without the SIGIO they would lose
>    their lease or would have to just take the lease for each GUP pin (which
>    adds overhead).  Like I said I did not like this but I left it to get
>    something which works out.

So to be clear.. 

Even though the lease is broken the GUP remains, the pages remain
pined, and truncate/etc continues to fail? 

I like Jan's take on this actually.. see other email.

Jason

