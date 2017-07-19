Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 030386B0292
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:19:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v62so12911444pfd.10
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 15:19:14 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 123si696496pgd.200.2017.07.19.15.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 15:19:13 -0700 (PDT)
Date: Wed, 19 Jul 2017 18:19:02 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 09/10] percpu: replace area map allocator with bitmap
 allocator
Message-ID: <20170719221901.GA99179@dennisz-mbp.dhcp.thefacebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-10-dennisz@fb.com>
 <20170719191105.GC23135@li70-116.members.linode.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170719191105.GC23135@li70-116.members.linode.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

Hi Josef,

On Wed, Jul 19, 2017 at 07:11:06PM +0000, Josef Bacik wrote:
> 
> This was a bear to review, I feel like it could be split into a few smaller
> pieces.  You are changing hinting, allocating/freeing, and how you find chunks.
> Those seem like good logical divisions to me.  Overall the design seems sound
> and I didn't spot any major problems.  Once you've split them up I'll do another
> thorough comb through and then add my reviewed by.  Thanks,

Yeah.. Thanks for taking the time. I'm currently working on responding
to Tejun's feedback and will do my best to split it down further. I've
done a bit of refactoring which should help readability and hopefully
make it easier in the next pass.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
