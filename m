Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 24F4E6B0388
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 19:37:34 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 65so74209415pgi.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 16:37:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s81si5973690pgs.29.2017.03.01.16.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 16:37:32 -0800 (PST)
Date: Wed, 1 Mar 2017 16:37:31 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302003731.GB24593@infradead.org>
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiong Zhou <xzhou@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Mar 01, 2017 at 12:46:34PM +0800, Xiong Zhou wrote:
> Hi,
> 
> It's reproduciable, not everytime though. Ext4 works fine.

On ext4 fsstress won't run bulkstat because it doesn't exist.  Either
way this smells like a MM issue to me as there were not XFS changes
in that area recently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
