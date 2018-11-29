Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8CF6B51C4
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 04:04:55 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e17so764896edr.7
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 01:04:55 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4-v6si383748eje.73.2018.11.29.01.04.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 01:04:53 -0800 (PST)
Date: Thu, 29 Nov 2018 10:04:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] fs: Don't open-code lru_to_page
Message-ID: <20181129090450.GR6923@dhcp22.suse.cz>
References: <20181129075301.29087-1-nborisov@suse.com>
 <20181129075301.29087-2-nborisov@suse.com>
 <20181129081826.GO6923@dhcp22.suse.cz>
 <0921bc8f-b899-4925-51f2-a9f45d4c906a@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0921bc8f-b899-4925-51f2-a9f45d4c906a@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Mark Fasheh <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>, Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, YueHaibing <yuehaibing@huawei.com>, Shakeel Butt <shakeelb@google.com>, Dan Williams <dan.j.williams@intel.com>, linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, devel@lists.orangefs.org, linux-mm@kvack.org

On Thu 29-11-18 10:50:08, Nikolay Borisov wrote:
> 
> 
> On 29.11.18 г. 10:18 ч., Michal Hocko wrote:
> > On Thu 29-11-18 09:52:57, Nikolay Borisov wrote:
> >> There are a bunch of filesystems which essentially open-code lru_to_page
> >> helper. Change them to using the helper. No functional changes.
> > 
> > I would just squash the two into a single patch. It makes the first one
> > more obvious. Or is there any reason to have them separate?
> 
> No reason, just didn't know how people would react so that's why I chose
> to send as two separate.

This is a matter of taste I guess. But I usually prefer to have callers
along with a new helper in a single patch. This is not a new helper
per-se but doing it the same way seems reasonable to me. Not that I
would insist of course. You can use my ack for both patch in case you
decide to leave it as is.

> If I squash them who would be the best person to take them ?

Sounds like a mmotm material to me.
-- 
Michal Hocko
SUSE Labs
