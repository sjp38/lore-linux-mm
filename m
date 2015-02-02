Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 56C606B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 12:08:21 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so84709959pad.7
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 09:08:21 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id yg1si24269645pbb.119.2015.02.02.09.08.20
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 09:08:20 -0800 (PST)
Message-ID: <54CFAF1C.4050104@fb.com>
Date: Mon, 2 Feb 2015 10:08:44 -0700
From: Jens Axboe <axboe@fb.com>
MIME-Version: 1.0
Subject: Re: backing_dev_info cleanups & lifetime rule fixes V2
References: <1421228561-16857-1-git-send-email-hch@lst.de> <54BEC3C2.7080906@fb.com> <20150201063116.GP29656@ZenIV.linux.org.uk> <20150202080635.GB9851@lst.de>
In-Reply-To: <20150202080635.GB9851@lst.de>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On 02/02/2015 01:06 AM, Christoph Hellwig wrote:
> On Sun, Feb 01, 2015 at 06:31:16AM +0000, Al Viro wrote:
>> And at that point we finally can make sb_lock and super_blocks static in
>> fs/super.c.  Do you want that in your tree, or would you rather have it
>> done via vfs.git during the merge window after your tree goes in?  It's
>> as trivial as this:
>>
>> Make super_blocks and sb_lock static
>>
>> The only user outside of fs/super.c is gone now
>>
>> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> I'd say merge it through the block tree..
> 
> Acked-by: Christoph Hellwig <hch@lst.de>

Added to for-3.20/bdi


-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
