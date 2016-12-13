Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3B66B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 17:07:43 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id z187so7499771iod.3
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 14:07:43 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0097.hostedemail.com. [216.40.44.97])
        by mx.google.com with ESMTPS id m76si35460023iod.253.2016.12.13.14.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 14:07:42 -0800 (PST)
Message-ID: <1481666853.29291.33.camel@perches.com>
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
From: Joe Perches <joe@perches.com>
Date: Tue, 13 Dec 2016 14:07:33 -0800
In-Reply-To: <20161213101451.GB10492@dhcp22.suse.cz>
References: <20161208103300.23217-1-mhocko@kernel.org>
	 <20161213101451.GB10492@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, Mikulas Patocka <mpatocka@redhat.com>

On Tue, 2016-12-13 at 11:14 +0100, Michal Hocko wrote:
> Are there any more comments or objections to this patch? Is this a good
> start or kv[mz]alloc has to provide a way to cover GFP_NOFS users as
> well in the initial version.

Did Andrew Morton ever comment on this?
I believe he was the primary objector in the past.

Last I recollect was over a year ago:

https://lkml.org/lkml/2015/7/7/1050


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
