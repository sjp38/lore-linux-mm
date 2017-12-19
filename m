Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 528A96B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 18:01:49 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l33so12139040wrl.5
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:01:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 184si1999526wmv.207.2017.12.19.15.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 15:01:48 -0800 (PST)
Date: Tue, 19 Dec 2017 15:01:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Provide useful debugging information for VM_BUG
Message-Id: <20171219150145.0b3875120ed336970d75b2f7@linux-foundation.org>
In-Reply-To: <20171219150212.GB30842@bombadil.infradead.org>
References: <20171219133236.GE13680@bombadil.infradead.org>
	<20171219144211.GY2787@dhcp22.suse.cz>
	<20171219150212.GB30842@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "Tobin C. Harding" <me@tobin.cc>, kernel-hardening@lists.openwall.com

On Tue, 19 Dec 2017 07:02:12 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> > > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks.  Andrew, will you take this, or does it go through the hardening tree?

I've queued it for 4.15.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
