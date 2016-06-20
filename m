Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE6A76B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 07:15:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so25892927wmr.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 04:15:16 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id q193si15273412wme.33.2016.06.20.04.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 04:15:15 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r201so13205362wme.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 04:15:15 -0700 (PDT)
Date: Mon, 20 Jun 2016 13:15:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv9-rebased2 01/37] mm, thp: make swapin readahead under
 down_read of mmap_sem
Message-ID: <20160620111514.GB9892@dhcp22.suse.cz>
References: <04f701d1c797$1ebe6b80$5c3b4280$@alibaba-inc.com>
 <04f801d1c79b$b46744a0$1d35cde0$@alibaba-inc.com>
 <20160616100854.GB18137@node.shutemov.name>
 <20160618190951.GA11151@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160618190951.GA11151@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat 18-06-16 22:09:51, Ebru Akagunduz wrote:
[...]
> This changelog really seems poor.
> Is there a way to update only changelog of the commit?

git commit --amend would do that for the current commit. You can also
tell git rebase -i to 'reword' a particular commits.
> Could you please suggest me a way to replace above changelog with the old?

Just tell Andrew, he can replace the changelog in his tree.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
