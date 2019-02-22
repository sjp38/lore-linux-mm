Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C03B0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:07:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 766202075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:07:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="FjSG5S0f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 766202075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0930E8E013A; Fri, 22 Feb 2019 17:07:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0411E8E013E; Fri, 22 Feb 2019 17:07:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4C008E013A; Fri, 22 Feb 2019 17:07:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE1F28E0137
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 17:07:00 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 43so3351237qtz.8
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:07:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wvCRxbJYSczzDq8esCNMsxZUKAQDzevDdhhdz/KvRNQ=;
        b=CX6dSO9u24RTl3bpfjIZQLlmQ18qe6c9ipgRMwDLRhpX3wbq/nSQxh4fp4RCM3TAgA
         SVRzFSCXxUry/7hF57a2FTUtcCa4NsoIi6v8Q9iVUQgJmMnVuvlxj0J/JrJe5UI6iTu+
         QUkx160nmiYCl6twtQRUMHQkVkQd1LqrYr00SXfcwD6J+4pEctEIL//XS5zUuSr5Vk9h
         XGW/dUMRE5blWTfJN/IRJ0PEz6CQ7+8Ax7GcwhFXMp2bECfBO4HE8usFPJgpn8bSDDKO
         QBonaI089RJrtOhw/BhfaQ+kH0yg4qfqDIEG5Jd/FDNV+dNhBoQniPdbqojeEPKqdWJv
         ++Sg==
X-Gm-Message-State: AHQUAubJO7xWBkdl4LHkStgF5rUZCqU/ZGq+gYPEJFlcgpACO3RYU6U/
	XOCB6DPIy9wMZtw3+bSfxIc/FdREydBruLAHUL2W6EBOW40n0nwSBnqajueisYTflOD1OTfvjek
	d0w0eNgFfyh4rwD5SNQTV9YDwDFUbB8OtgbLQ7Ur7mLSApYQxcmNwKnhp27X9TFYuqyE2l6bvjK
	ZiLyIBgdwYRophD7Z0bYv89xFlp3NGVLaldu4gvq1M/gNY79FSEIcKabd4DPMYPioezZm0+Wop4
	WYJstqN81++vneDGfjXe7/bMVW+CzfflkEAQTKJuHOWMsr9E3DBXBCFpTMf5klF3XHvTPpiD7jb
	dUfVQUqps1EAm91U+XzTEpa01Z90H6Y06gC7OtstPmI2GC6TNNA6N/G5g6JxfbyhNb0HqKsYZ5P
	P
X-Received: by 2002:ac8:312c:: with SMTP id g41mr5095378qtb.22.1550873220530;
        Fri, 22 Feb 2019 14:07:00 -0800 (PST)
X-Received: by 2002:ac8:312c:: with SMTP id g41mr5095348qtb.22.1550873219888;
        Fri, 22 Feb 2019 14:06:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550873219; cv=none;
        d=google.com; s=arc-20160816;
        b=VYJw4UkO5dLRAWAwk4DaVUTPypbPle7akcAu2dq0mxuV70hMmE3aRReWd0uq8YbYjx
         HCp5jTpdkQ7RTPQ/oNlkyJKjYcuXYZZClOiBgKjGRJjSgTgCh1k988lQx9yprKiw044H
         d67mjEazGUCm48xI55/qZI+9XOjcwVDZVRcyf9+jVFNd+pwJ5ZrrtHa65GyRTZW+kDXG
         f5jmXcAqG8NAzu2XLeRO15Z8IsRIlTp9Cd8AtkWuKjhzWcECleH4Dn8jWq0bi2Y4i6LR
         1pfqMQYpwGjaPDvw875r5sJvpmNh6vkb3S0a7tm257Clv006C/+A/dNEHVgbmvtjyc7d
         Z3rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=wvCRxbJYSczzDq8esCNMsxZUKAQDzevDdhhdz/KvRNQ=;
        b=aGw2owxcqFRsQkW7eqjCt0OAoluilZ33CeC6we+KPFfxq75gTpgeawAlqZXhG5QHaW
         tAZ7Xb8S0fT1One4CY4S/YXkyc40QIszM53Uvi03SddP8mGNyRCQ7nGhj6+AGkglZWXK
         9Em88ym7wnh2+n787BOWDUNRFrclhfIGJU+jRwmlcf//eu6WZdABwpPyBEBzqDVApJro
         ohEXdTSqjyf9woYZcPsXjeZcTTh1ISgFwypn4SbR9wWAiNTxWur4k5D2YL1sgokh66D8
         SuQMnCSw5QIfypWfyDBbNZI7znVA/qfHYpFWL+6pG2u0wzjGnrGgkiPOED1Y3qu6jTKT
         sTnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FjSG5S0f;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m89sor3491546qte.5.2019.02.22.14.06.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 14:06:59 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FjSG5S0f;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=wvCRxbJYSczzDq8esCNMsxZUKAQDzevDdhhdz/KvRNQ=;
        b=FjSG5S0fr+ZrmJ2CV+EZP3ZNWeviZCv91Vg1L72fZNrgtunR4NJzDFKIXprqCDKceo
         3PZCLGo4To6/ALctcLVcUmOM6TiefoDx/2u4Kjm5AhdGjM8kAVn8MFxA4945cHfYYSqp
         GF2vd5ChQL0y9jyeVoW4uevKBAFx6EOfDPSR1LpuhLGhDlHxg6TaR82OVSCgjB+DtQ67
         adepQG0a+MjN9yfsa3c8Vw3FFK3HFTavQj1LXhMtg7XUHUCf+uvWBRRJq2NkZv9Ejvye
         D5DVGI2PGyPBaIYad19+iFTBHc4WpeKL/QG2A92XJKlejyGLjr9eTX7LBF2II3frtaj3
         Aa1g==
X-Google-Smtp-Source: AHgI3IaZVy1jYHZkQ5nXcZJ5Xkaw61MhMb6Y/pVQvnSqgEACGhSVt7azaXHIkgpEOFnUBHE3BGr2kA==
X-Received: by 2002:ac8:254c:: with SMTP id 12mr4708917qtn.88.1550873219604;
        Fri, 22 Feb 2019 14:06:59 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id v80sm2006526qkv.34.2019.02.22.14.06.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 14:06:59 -0800 (PST)
Subject: Re: io_submit with slab free object overwritten
To: Eric Sandeen <sandeen@sandeen.net>, hch@lst.de
Cc: axboe@kernel.dk, viro@zeniv.linux.org.uk, hare@suse.com, bcrl@kvack.org,
 linux-aio@kvack.org, Linux-MM <linux-mm@kvack.org>, jthumshirn@suse.de,
 linux-fsdevel@vger.kernel.org, Christoph Lameter <cl@linux.com>
References: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
 <64b860a3-7946-ca72-8669-18ad01a78c7c@lca.pw>
 <0a28db73-7e52-9879-276c-adc6aaf05d4d@sandeen.net>
 <e2fdd737-2a48-ecea-10b8-f90d6866df34@lca.pw>
 <aeeed9ef-357e-4702-1e4b-ed85cab7ae34@sandeen.net>
From: Qian Cai <cai@lca.pw>
Message-ID: <fb8add28-41da-da16-8b3d-7c7f4d4b0b8a@lca.pw>
Date: Fri, 22 Feb 2019 17:06:56 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <aeeed9ef-357e-4702-1e4b-ed85cab7ae34@sandeen.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/22/19 4:58 PM, Eric Sandeen wrote:
> On 2/22/19 3:48 PM, Qian Cai wrote:
>>
>>
>> On 2/22/19 4:42 PM, Eric Sandeen wrote:
>>> On 2/22/19 3:07 PM, Qian Cai wrote:
>>>> Reverted the commit 75374d062756 ("fs: add an iopoll method to struct
>>>> file_operations") fixed the problem. Christoph mentioned that the field can be
>>>> calculated by the offset (40 bytes).
>>>
>>> I'm a little confused, you can't revert just that patch, right, because others
>>> in the iopoll series depend on it.  Is the above commit really the culprit, or do
>>> you mean you backed out the whole series?
>>
>> No, I can revert that single commit on the top of linux-next (next-20190222)
>> just fine.
> 
> Sorry for being pedantic, but this commit is still in your tree?  How can this build
> with just 75374d062756 reverted?
> 
> (I'm confused about how simply changing the size of the 2 structures via
> 75374d062756 could cause memory corruption, so trying to really understand
> what got tested...)
> 
> commit 06eca8c02eb3e171dc5721ddca4218d41b09b3aa
> Author: Christoph Hellwig <hch@lst.de>
> Date:   Fri Nov 30 08:31:52 2018 -0700
> 
>     block: wire up block device iopoll method
>     
>     Just call blk_poll on the iocb cookie, we can derive the block device
>     from the inode trivially.
>     
>     Reviewed-by: Hannes Reinecke <hare@suse.com>
>     Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>
>     Signed-off-by: Christoph Hellwig <hch@lst.de>
>     Signed-off-by: Jens Axboe <axboe@kernel.dk>
> 
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 7758ade..d1277a1 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -294,6 +294,14 @@ struct blkdev_dio {
>  
>  static struct bio_set blkdev_dio_pool;
>  
> +static int blkdev_iopoll(struct kiocb *kiocb, bool wait)
> +{
> +       struct block_device *bdev = I_BDEV(kiocb->ki_filp->f_mapping->host);
> +       struct request_queue *q = bdev_get_queue(bdev);
> +
> +       return blk_poll(q, READ_ONCE(kiocb->ki_cookie), wait);
> +}
> +
>  static void blkdev_bio_end_io(struct bio *bio)
>  {
>         struct blkdev_dio *dio = bio->bi_private;
> @@ -412,6 +420,7 @@ __blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, int nr_pages)
>                                 bio->bi_opf |= REQ_HIPRI;
>  
>                         qc = submit_bio(bio);
> +                       WRITE_ONCE(iocb->ki_cookie, qc);
>                         break;
>                 }
>  
> @@ -2078,6 +2087,7 @@ const struct file_operations def_blk_fops = {
>         .llseek         = block_llseek,
>         .read_iter      = blkdev_read_iter,
>         .write_iter     = blkdev_write_iter,
> +       .iopoll         = blkdev_iopoll,
>         .mmap           = generic_file_mmap,
>         .fsync          = blkdev_fsync,
>         .unlocked_ioctl = block_ioctl,
> 

Sorry, I had a copy-and-paste error here while looking at the surrounding
commits. I meant,

Reverted 06eca8c02eb3 (block: wire up block device iopoll method) fixed the problem.

