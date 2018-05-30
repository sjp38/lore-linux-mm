Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC7C96B029C
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:02:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l7-v6so16344864qkk.20
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:02:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v129-v6si1785271qka.94.2018.05.30.03.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 03:02:13 -0700 (PDT)
Subject: Re: [Cluster-devel] [PATCH 11/34] iomap: move IOMAP_F_BOUNDARY to
 gfs2
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-12-hch@lst.de> <20180530055033.GZ30110@magnolia>
 <bc621d7c-f1a6-14c2-663f-57ded16811fa@redhat.com>
 <20180530095911.GB31068@lst.de>
From: Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <e14b3cfb-73ca-e712-e1e9-4ceabc8c7b6d@redhat.com>
Date: Wed, 30 May 2018 11:02:08 +0100
MIME-Version: 1.0
In-Reply-To: <20180530095911.GB31068@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com, linux-mm@kvack.org, =?UTF-8?Q?Andreas_Gr=c3=bcnbacher?= <agruenba@redhat.com>

Hi,


On 30/05/18 10:59, Christoph Hellwig wrote:
> On Wed, May 30, 2018 at 10:30:32AM +0100, Steven Whitehouse wrote:
>> I may have missed the context here, but I thought that the boundary wa=
s a
>> generic thing meaning "there will have to be a metadata read before mo=
re
>> blocks can be mapped" so I'm not sure why that would now be GFS2 speci=
fic?
> It was always a hack.  But with iomap it doesn't make any sensee to sta=
rt
> with, all metadata I/O happens in iomap_begin, so there is no point in
> marking an iomap with flags like this for the actual iomap interface.

In that case,=C2=A0 maybe it would be simpler to drop it for GFS2. Unless=
 we=20
are getting a lot of benefit from it, then we should probably just=20
follow the generic pattern here. Eventually we'll move everything to=20
iomap, so that the bh mapping interface will be gone. That implies that=20
we might be able to drop it now, to avoid this complication during the=20
conversion.

Andreas, do you see any issues with that?

Steve.
