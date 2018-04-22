Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE4A36B000C
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 16:33:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 31-v6so15774278wrr.2
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 13:33:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b3si104306edh.368.2018.04.22.13.33.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Apr 2018 13:33:30 -0700 (PDT)
Subject: Re: [PATCH v11 10/63] xarray: Add xa_for_each
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-11-willy@infradead.org>
 <35a3318d-69d7-a10c-1515-98ea6b59fb99@suse.de>
 <20180421013406.GM10788@bombadil.infradead.org>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <3c759f62-a1fa-9bdd-9b02-7c4e1d2b3adb@suse.de>
Date: Sun, 22 Apr 2018 15:33:23 -0500
MIME-Version: 1.0
In-Reply-To: <20180421013406.GM10788@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>



On 04/20/2018 08:34 PM, Matthew Wilcox wrote:
> On Fri, Apr 20, 2018 at 07:00:47AM -0500, Goldwyn Rodrigues wrote:

>> This function name sounds like you are performing the operation for each
>> tag.
>>
>> Can it be called xas_for_each_tagged() or xas_tag_for_each() instead?
> 
> I hadn't thought of that interpretation.  Yes, that makes sense.
> Should we also rename xas_find_tag -> xas_find_tagged and xas_next_tag
> -> xas_next_tagged?

Yup. The family of functions that work with one tag should be renamed. I
am fine with the names suggested.


-- 
Goldwyn
