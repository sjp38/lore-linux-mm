Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABC026B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 00:19:02 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id n127so87201919qkf.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 21:19:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v34si1877256qtv.262.2017.03.01.21.19.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 21:19:02 -0800 (PST)
Date: Thu, 2 Mar 2017 13:19:00 +0800
From: Xiong Zhou <xzhou@redhat.com>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
 <20170302003731.GB24593@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302003731.GB24593@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, mhocko@suse.com
Cc: Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Mar 01, 2017 at 04:37:31PM -0800, Christoph Hellwig wrote:
> On Wed, Mar 01, 2017 at 12:46:34PM +0800, Xiong Zhou wrote:
> > Hi,
> > 
> > It's reproduciable, not everytime though. Ext4 works fine.
> 
> On ext4 fsstress won't run bulkstat because it doesn't exist.  Either
> way this smells like a MM issue to me as there were not XFS changes
> in that area recently.

Yap.

First bad commit:

commit 5d17a73a2ebeb8d1c6924b91e53ab2650fe86ffb
Author: Michal Hocko <mhocko@suse.com>
Date:   Fri Feb 24 14:58:53 2017 -0800

    vmalloc: back off when the current task is killed

Reverting this commit on top of
  e5d56ef Merge tag 'watchdog-for-linus-v4.11'
survives the tests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
