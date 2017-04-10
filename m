Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8D46B0038
	for <linux-mm@kvack.org>; Sun,  9 Apr 2017 23:11:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n129so118023900pga.0
        for <linux-mm@kvack.org>; Sun, 09 Apr 2017 20:11:47 -0700 (PDT)
Received: from out0-194.mail.aliyun.com (out0-194.mail.aliyun.com. [140.205.0.194])
        by mx.google.com with ESMTP id g3si12333690pgf.153.2017.04.09.20.11.46
        for <linux-mm@kvack.org>;
        Sun, 09 Apr 2017 20:11:46 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1491586995-13085-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1491586995-13085-1-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [PATCH] Documentation: vm, add hugetlbfs reservation overview
Date: Mon, 10 Apr 2017 11:11:43 +0800
Message-ID: <0a0401d2b1a8$2e7e58e0$8b7b0aa0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: 'Jonathan Corbet' <corbet@lwn.net>, 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>


On April 08, 2017 1:43 AM Mike Kravetz wrote: 
> 
> Adding a brief overview of hugetlbfs reservation design and implementation
> as an aid to those making code modifications in this area.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
You are doing more than I can double thank you, Mike:)

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
