Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 361056B0038
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 15:00:43 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id g49so105302416qta.0
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 12:00:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k71si14947837qkl.47.2017.01.16.12.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 12:00:42 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
References: <20170114002008.GA25379@linux.intel.com>
	<20170114082621.GC10498@birch.djwong.org>
Date: Mon, 16 Jan 2017 15:00:41 -0500
In-Reply-To: <20170114082621.GC10498@birch.djwong.org> (Darrick J. Wong's
	message of "Sat, 14 Jan 2017 00:26:21 -0800")
Message-ID: <x49wpduzseu.fsf@dhcp-25-115.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

"Darrick J. Wong" <darrick.wong@oracle.com> writes:

>> - Whenever you mount a filesystem with DAX, it spits out a message that says
>>   "DAX enabled. Warning: EXPERIMENTAL, use at your own risk".  What criteria
>>   needs to be met for DAX to no longer be considered experimental?
>
> For XFS I'd like to get reflink working with it, for starters.

What do you mean by this, exactly?  When Dave outlined the requirements
for PMEM_IMMUTABLE, it was very clear that metadata updates would not be
possible.  And would you really cosider this a barrier to marking dax
fully supported?  I wouldn't.

> We probably need a bunch more verification work to show that file IO
> doesn't adopt any bad quirks having turned on the per-inode DAX flag.

Can you be more specific?  We have ltp and xfstests.  If you have some
mkfs/mount options that you think should be tested, speak up.  Beyond
that, if it passes ./check -g auto and ltp, are we good?

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
