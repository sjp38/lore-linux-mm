Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4009D6B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 12:54:33 -0500 (EST)
Received: by wevm14 with SMTP id m14so20269546wev.13
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 09:54:32 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id fw17si18902102wic.118.2015.02.23.09.54.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 09:54:32 -0800 (PST)
Message-ID: <54EB6950.6030909@fb.com>
Date: Mon, 23 Feb 2015 09:54:24 -0800
From: Jens Axboe <axboe@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: shmem: check for mapping owner before dereferencing
References: <1424687880-8916-1-git-send-email-sasha.levin@oracle.com> <20150223174912.GA25675@lst.de>
In-Reply-To: <20150223174912.GA25675@lst.de>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Sasha Levin <sasha.levin@oracle.com>
Cc: hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, jack@suse.cz

On 02/23/2015 09:49 AM, Christoph Hellwig wrote:
> Looks good,
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Shall I funnel this through for-linus?


-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
