Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id A77006B039F
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:47:31 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id r137so130953768ywg.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:47:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h7si1003538ybi.254.2017.03.02.07.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:47:30 -0800 (PST)
Date: Thu, 2 Mar 2017 07:47:25 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302154725.GA28457@infradead.org>
References: <20170302103520.GC1404@dhcp22.suse.cz>
 <20170302122426.GA3213@bfoster.bfoster>
 <20170302124909.GE1404@dhcp22.suse.cz>
 <20170302130009.GC3213@bfoster.bfoster>
 <20170302132755.GG1404@dhcp22.suse.cz>
 <20170302134157.GD3213@bfoster.bfoster>
 <20170302135001.GI1404@dhcp22.suse.cz>
 <20170302142315.GE3213@bfoster.bfoster>
 <20170302143441.GL1404@dhcp22.suse.cz>
 <20170302145131.GF3213@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302145131.GF3213@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, Mar 02, 2017 at 09:51:31AM -0500, Brian Foster wrote:
> Otherwise, I'm fine with breaking the infinite retry loop at the same
> time. It looks like Christoph added this function originally so this
> should probably require his ack as well..

I just moved the code around, but I'll take a look as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
