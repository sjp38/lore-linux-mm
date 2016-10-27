Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7936B028C
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 06:22:54 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y138so7457676wme.7
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:22:54 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 135si2315895wmx.57.2016.10.27.03.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 03:22:53 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id c17so1931602wmc.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:22:53 -0700 (PDT)
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com>
 <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
 <20161020232239.GQ23194@dastard> <20161021095714.GA12209@infradead.org>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <76e957c9-8002-5a46-8111-269bb0401718@grimberg.me>
Date: Thu, 27 Oct 2016 13:22:49 +0300
MIME-Version: 1.0
In-Reply-To: <20161021095714.GA12209@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>
Cc: jgunthorpe@obsidianresearch.com, sbates@raithin.com, "Raj, Ashok" <ashok.raj@intel.com>, haggaie@mellanox.com, linux-rdma@vger.kernel.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Jonathan Corbet <corbet@lwn.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, jim.macdonald@everspin.com, Stephen Bates <sbates@raithlin.com>, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jens Axboe <axboe@fb.com>, David Woodhouse <dwmw2@infradead.org>


>> You do realise that local filesystems can silently change the
>> location of file data at any point in time, so there is no such
>> thing as a "stable mapping" of file data to block device addresses
>> in userspace?
>>
>> If you want remote access to the blocks owned and controlled by a
>> filesystem, then you need to use a filesystem with a remote locking
>> mechanism to allow co-ordinated, coherent access to the data in
>> those blocks. Anything else is just asking for ongoing, unfixable
>> filesystem corruption or data leakage problems (i.e.  security
>> issues).
>
> And at least for XFS we have such a mechanism :)  E.g. I have a
> prototype of a pNFS layout that uses XFS+DAX to allow clients to do
> RDMA directly to XFS files, with the same locking mechanism we use
> for the current block and scsi layout in xfs_pnfs.c.

Christoph, did you manage to leap to the future and solve the
RDMA persistency hole? :)

e.g. what happens with O_DSYNC in this model? Or you did
a message exchange for commits?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
