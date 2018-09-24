Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22E7E8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:09:41 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id w132-v6so4839253ita.6
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:09:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p55-v6sor7328952jak.100.2018.09.24.11.09.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 11:09:40 -0700 (PDT)
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180921130504.GA22551@lst.de>
 <010001660c54fb65-b9d3a770-6678-40d0-8088-4db20af32280-000000@email.amazonses.com>
 <1f88f59a-2cac-e899-4c2e-402e919b1034@kernel.dk>
 <010001660cbd51ea-56e96208-564d-4f5d-a5fb-119a938762a9-000000@email.amazonses.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <1a5b255f-682e-783a-7f99-9d02e39c4af2@kernel.dk>
Date: Mon, 24 Sep 2018 12:09:37 -0600
MIME-Version: 1.0
In-Reply-To: <010001660cbd51ea-56e96208-564d-4f5d-a5fb-119a938762a9-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Christoph Hellwig <hch@lst.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ming Lei <ming.lei@redhat.com>

On 9/24/18 12:00 PM, Christopher Lameter wrote:
> On Mon, 24 Sep 2018, Jens Axboe wrote:
> 
>> The situation is making me a little uncomfortable, though. If we export
>> such a setting, we really should be honoring it...
> 
> Various subsystems create custom slab arrays with their particular
> alignment requirement for these allocations.

Oh yeah, I think the solution is basic enough for XFS, for instance.
They just have to error on the side of being cautious, by going full
sector alignment for memory...

-- 
Jens Axboe
