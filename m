Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E11F76B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:57:39 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f5so82313197pgi.1
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:57:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id k190si24104091pge.246.2017.01.16.23.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 23:57:39 -0800 (PST)
Date: Mon, 16 Jan 2017 23:57:35 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
Message-ID: <20170117075735.GB19654@infradead.org>
References: <20170114002008.GA25379@linux.intel.com>
 <20170114082621.GC10498@birch.djwong.org>
 <x49wpduzseu.fsf@dhcp-25-115.bos.redhat.com>
 <20170117015033.GD10498@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117015033.GD10498@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 16, 2017 at 05:50:33PM -0800, Darrick J. Wong wrote:
> I wouldn't consider it a barrier in general (since ext4 also prints
> EXPERIMENTAL warnings for DAX), merely one for XFS.  I don't even think
> it's that big of a hurdle -- afaict XFS ought to be able to achieve this
> by modifying iomap_begin to allocate new pmem blocks, memcpy the
> contents, and update the memory mappings.  I think.

Yes, and I have a working prototype for that.  I'm just way to busy
with lots of bugfixing at the moment but I plan to get to it in this
merge window.  I also agree that we can't mark a feature as fully
supported until it doesn't conflict with other features.

And I'm not going to get start on the PMEM_IMMUTABLE bullshit, please
don't even go there folks, it's a dead end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
