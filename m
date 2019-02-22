Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 752F4C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:58:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C4022075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:58:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C4022075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sandeen.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B97548E013D; Fri, 22 Feb 2019 16:58:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B44A68E013A; Fri, 22 Feb 2019 16:58:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E6198E013D; Fri, 22 Feb 2019 16:58:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 735118E0137
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 16:58:05 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id j127so3018739itj.7
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:58:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=wqw8fd41FVK9++6lI+HsWjzNmYTGwkeSDlGhttyhk5U=;
        b=PeypLlA79YEnuBazW00BzpAS7WuBaVZgJjklrf/zjkrDdfYX+mdwvfFnyKwTzrF+c9
         kMXWl9ZEgvZ/IkmXB2J7h5APknVR63cmHUkRNkT/PzACKHi9PL/h3DBajcgFOxmYT7fG
         rLuDmanSbjGLfYSH5uWE4u3M3qY8BiGpsLIWLXEg6pNzQ9ZaMqpqLIuHJoUwQ4mcBe68
         3rBFvSGuUNEuLXrYPkTSsFR30iQM1uYzKD1aern2dkbtIH0ItnP2AtcE36M5c+ciT0/S
         M9XJFUuDbJmrTWcPJIo79ASxhhRQwwwFGc5cTmmNn6UQhuuAGewy3HJd1jOGz8SJ4SGe
         B6fQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sandeen@sandeen.net designates 63.231.237.45 as permitted sender) smtp.mailfrom=sandeen@sandeen.net
X-Gm-Message-State: AHQUAuZvb6hsQ2cPnWT6+HIltycbNCY08gYRz1Ppf04Mv9l6W2JyGqIu
	uvC5WzEu2pE4pXWozxwXyPWeNA/2IQSlk6HJhl7mJ5Bpy9s5i3FMcTYP2gisoSqmp2uMRSaCFmw
	SajhGQFFCEq3aP7oeTHwIQQLdf4yUEu+MHNN3COecMvQiaF91+vDn+RPxS0HlhBZ0VQ==
X-Received: by 2002:a5d:8190:: with SMTP id u16mr3837612ion.238.1550872685240;
        Fri, 22 Feb 2019 13:58:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbX/sOj4gQd0XFv6sNw4hXNA47Ioj2/cY+/YZgpt7CgUhKZk+CBCQfWECqkoprVh7WckC80
X-Received: by 2002:a5d:8190:: with SMTP id u16mr3837576ion.238.1550872684470;
        Fri, 22 Feb 2019 13:58:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550872684; cv=none;
        d=google.com; s=arc-20160816;
        b=YOII1jhNBaf75lAfTvGcDVpfeix9Woz2MfMKDq8cug8wZ/6MAGLsLEC0Kc6DBmoFeg
         2rY1laGS3lZeY6r/iqWN4enjr8zPIeQuGPXWW4IOYp3eG/Tf1ZT5AIG6jM0Q+szIhpn/
         KUZZNO9F4d5iENdSFLx43tptcD67GFFkKG8S2gATqAj23s1BFDkmiYDcxLM5K/EfRs7j
         CNJgtP5NVLmhBCyQEKXtgor3gZMeeM9cYPvufNDQyYCljypDuOOlyCwQL4WmJgN81eV1
         Esu7eUVdN+ZohrVewXcC+28VOQzmrBudDvJlVeB03wKGnrP7kZF84az9ImD77bFNBkd0
         EJgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=wqw8fd41FVK9++6lI+HsWjzNmYTGwkeSDlGhttyhk5U=;
        b=U2SWF1Y+FPYezuBXD96P+QTUuEqc+MKawnd150rJobRcX0ViJWajHbjHQpHI1uQC4j
         945uRlXwlJbvlfFPFaIgGjK3BVJPdX8i+MIb/THqIomn/KhZEjI2if2kmjafRCjnTcyt
         m3JkcemsMru2J/jIFivcTI/8Pggi83FBu+J/DlPm6ZLa2Wlw7fK9AjEGZ6kFgB8J0cKn
         HVhp/bA5jWzNH3NrhnFQTRE+6ntr/XLSCmxUK+fqPyrogA7QxM2JQqvld9QIN9HiO9pN
         d5vtC/tL4FDVdJDb/MgKWXd6prTkbO0pMhqYDqoISJws7xUPEap+tT9A6cK9rLxTQgpL
         gaMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sandeen@sandeen.net designates 63.231.237.45 as permitted sender) smtp.mailfrom=sandeen@sandeen.net
Received: from sandeen.net (sandeen.net. [63.231.237.45])
        by mx.google.com with ESMTP id h139si1428266itb.101.2019.02.22.13.58.04;
        Fri, 22 Feb 2019 13:58:04 -0800 (PST)
Received-SPF: pass (google.com: domain of sandeen@sandeen.net designates 63.231.237.45 as permitted sender) client-ip=63.231.237.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sandeen@sandeen.net designates 63.231.237.45 as permitted sender) smtp.mailfrom=sandeen@sandeen.net
Received: from [10.0.0.4] (liberator [10.0.0.4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by sandeen.net (Postfix) with ESMTPSA id DBEFE326E;
	Fri, 22 Feb 2019 15:57:44 -0600 (CST)
Subject: Re: io_submit with slab free object overwritten
To: Qian Cai <cai@lca.pw>, hch@lst.de
Cc: axboe@kernel.dk, viro@zeniv.linux.org.uk, hare@suse.com, bcrl@kvack.org,
 linux-aio@kvack.org, Linux-MM <linux-mm@kvack.org>, jthumshirn@suse.de,
 linux-fsdevel@vger.kernel.org, Christoph Lameter <cl@linux.com>
References: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
 <64b860a3-7946-ca72-8669-18ad01a78c7c@lca.pw>
 <0a28db73-7e52-9879-276c-adc6aaf05d4d@sandeen.net>
 <e2fdd737-2a48-ecea-10b8-f90d6866df34@lca.pw>
From: Eric Sandeen <sandeen@sandeen.net>
Openpgp: preference=signencrypt
Autocrypt: addr=sandeen@sandeen.net; prefer-encrypt=mutual; keydata=
 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 pA==
Message-ID: <aeeed9ef-357e-4702-1e4b-ed85cab7ae34@sandeen.net>
Date: Fri, 22 Feb 2019 15:58:02 -0600
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <e2fdd737-2a48-ecea-10b8-f90d6866df34@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/22/19 3:48 PM, Qian Cai wrote:
> 
> 
> On 2/22/19 4:42 PM, Eric Sandeen wrote:
>> On 2/22/19 3:07 PM, Qian Cai wrote:
>>> Reverted the commit 75374d062756 ("fs: add an iopoll method to struct
>>> file_operations") fixed the problem. Christoph mentioned that the field can be
>>> calculated by the offset (40 bytes).
>>
>> I'm a little confused, you can't revert just that patch, right, because others
>> in the iopoll series depend on it.  Is the above commit really the culprit, or do
>> you mean you backed out the whole series?
> 
> No, I can revert that single commit on the top of linux-next (next-20190222)
> just fine.

Sorry for being pedantic, but this commit is still in your tree?  How can this build
with just 75374d062756 reverted?

(I'm confused about how simply changing the size of the 2 structures via
75374d062756 could cause memory corruption, so trying to really understand
what got tested...)

commit 06eca8c02eb3e171dc5721ddca4218d41b09b3aa
Author: Christoph Hellwig <hch@lst.de>
Date:   Fri Nov 30 08:31:52 2018 -0700

    block: wire up block device iopoll method
    
    Just call blk_poll on the iocb cookie, we can derive the block device
    from the inode trivially.
    
    Reviewed-by: Hannes Reinecke <hare@suse.com>
    Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>
    Signed-off-by: Christoph Hellwig <hch@lst.de>
    Signed-off-by: Jens Axboe <axboe@kernel.dk>

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 7758ade..d1277a1 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -294,6 +294,14 @@ struct blkdev_dio {
 
 static struct bio_set blkdev_dio_pool;
 
+static int blkdev_iopoll(struct kiocb *kiocb, bool wait)
+{
+       struct block_device *bdev = I_BDEV(kiocb->ki_filp->f_mapping->host);
+       struct request_queue *q = bdev_get_queue(bdev);
+
+       return blk_poll(q, READ_ONCE(kiocb->ki_cookie), wait);
+}
+
 static void blkdev_bio_end_io(struct bio *bio)
 {
        struct blkdev_dio *dio = bio->bi_private;
@@ -412,6 +420,7 @@ __blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, int nr_pages)
                                bio->bi_opf |= REQ_HIPRI;
 
                        qc = submit_bio(bio);
+                       WRITE_ONCE(iocb->ki_cookie, qc);
                        break;
                }
 
@@ -2078,6 +2087,7 @@ const struct file_operations def_blk_fops = {
        .llseek         = block_llseek,
        .read_iter      = blkdev_read_iter,
        .write_iter     = blkdev_write_iter,
+       .iopoll         = blkdev_iopoll,
        .mmap           = generic_file_mmap,
        .fsync          = blkdev_fsync,
        .unlocked_ioctl = block_ioctl,

