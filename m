Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 22DA16B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 17:36:03 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so2526880iec.21
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:36:03 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id j4si6562959igx.34.2014.06.19.14.36.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 14:36:02 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so3902653igb.5
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:36:02 -0700 (PDT)
Date: Thu, 19 Jun 2014 14:36:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/mem-hotplug: replace simple_strtoull() with
 kstrtoull()
In-Reply-To: <53A2AEB4.40608@huawei.com>
Message-ID: <alpine.DEB.2.02.1406191435460.8611@chino.kir.corp.google.com>
References: <1403170456-25054-1-git-send-email-zhenzhang.zhang@huawei.com> <53A2AEB4.40608@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: nfont@austin.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, 19 Jun 2014, Zhang Zhen wrote:

> use the newer and more pleasant kstrtoull() to replace simple_strtoull(),
> because simple_strtoull() is marked for obsoletion.
> 
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
