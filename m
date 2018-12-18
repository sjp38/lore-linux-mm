Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C53E8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 11:31:47 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so14130019pgm.4
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 08:31:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 44si13384590plc.110.2018.12.18.08.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Dec 2018 08:31:45 -0800 (PST)
Date: Tue, 18 Dec 2018 08:31:14 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Fix mm->owner point to a tsk that has been free
Message-ID: <20181218163114.GV10600@bombadil.infradead.org>
References: <1545110684-8730-1-git-send-email-gchen.guomin@gmail.com>
 <20181218095226.GD17870@dhcp22.suse.cz>
 <CAEEwsfRb-FDCLp-b3-n2+vvgWttv6FQhjkLxpJwA==_+89iY=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEEwsfRb-FDCLp-b3-n2+vvgWttv6FQhjkLxpJwA==_+89iY=w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gchen chen <gchen.guomin@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, gchen <guominchen@tencent.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 19, 2018 at 12:21:27AM +0800, gchen chen wrote:
> Oh, yes, the patch 39af176 has been skip the kthread
> on mm_update_next_owner .

Actually f87fb599ae4
