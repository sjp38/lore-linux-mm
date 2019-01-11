Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA9E8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:31:40 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id m3so10824569pfj.14
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 09:31:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 30si27050800pgv.191.2019.01.11.09.31.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 Jan 2019 09:31:38 -0800 (PST)
Date: Fri, 11 Jan 2019 09:31:32 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] rbtree: fix the red root
Message-ID: <20190111173132.GH6310@bombadil.infradead.org>
References: <YrcPMrGmYbPe_xgNEV6Q0jqc5XuPYmL2AFSyeNmg1gW531bgZnBGfEUK5_ktqDBaNW37b-NP2VXvlliM7_PsBRhSfB649MaW1Ne7zT9lHc=@protonmail.ch>
 <20190111165145.23628-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190111165145.23628-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 11, 2019 at 11:51:45AM -0500, Qian Cai wrote:
> Reported-by: Esme <esploit@protonmail.ch>
> Signed-off-by: Qian Cai <cai@lca.pw>

What change introduced this bug?  We need a Fixes: line so the stable
people know how far to backport this fix.
