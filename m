Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 654616B02A5
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:12:49 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m7-v6so15999400qtg.1
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:12:49 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v47-v6si1530938qtg.82.2018.05.30.03.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 03:12:47 -0700 (PDT)
Subject: Re: [Cluster-devel] [PATCH 11/34] iomap: move IOMAP_F_BOUNDARY to
 gfs2
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-12-hch@lst.de> <20180530055033.GZ30110@magnolia>
 <bc621d7c-f1a6-14c2-663f-57ded16811fa@redhat.com>
 <20180530095911.GB31068@lst.de>
 <e14b3cfb-73ca-e712-e1e9-4ceabc8c7b6d@redhat.com>
 <20180530101003.GA31419@lst.de>
From: Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <8a9e048b-f60c-90bc-6884-e2fa6eca2c28@redhat.com>
Date: Wed, 30 May 2018 11:12:43 +0100
MIME-Version: 1.0
In-Reply-To: <20180530101003.GA31419@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com, linux-mm@kvack.org, =?UTF-8?Q?Andreas_Gr=c3=bcnbacher?= <agruenba@redhat.com>

Hi,


On 30/05/18 11:10, Christoph Hellwig wrote:
> On Wed, May 30, 2018 at 11:02:08AM +0100, Steven Whitehouse wrote:
>> In that case,=C2=A0 maybe it would be simpler to drop it for GFS2. Unl=
ess we
>> are getting a lot of benefit from it, then we should probably just fol=
low
>> the generic pattern here. Eventually we'll move everything to iomap, s=
o
>> that the bh mapping interface will be gone. That implies that we might=
 be
>> able to drop it now, to avoid this complication during the conversion.=

>>
>> Andreas, do you see any issues with that?
> I suspect it actually is doing the wrong thing today.  It certainly
> does for SSDs, and it probably doesn't do a useful thing for modern
> disks with intelligent caches either.

Yes, agreed that it makes no sense for SSDs,

Steve.
