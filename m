Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 871BF6B0036
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 13:32:08 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id i8so6176363qcq.17
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 10:32:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w5si3580122qab.66.2014.04.11.10.32.05
        for <linux-mm@kvack.org>;
        Fri, 11 Apr 2014 10:32:05 -0700 (PDT)
Message-ID: <53482077.3030603@redhat.com>
Date: Fri, 11 Apr 2014 13:03:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: replace IS_ERR and PTR_ERR with PTR_ERR_OR_ZERO
References: <1397205423-24214-1-git-send-email-duanj.fnst@cn.fujitsu.com>
In-Reply-To: <1397205423-24214-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>, akpm@linux-foundation.org, oleg@redhat.com, walken@google.com, hughd@google.com
Cc: linux-mm@kvack.org

On 04/11/2014 04:37 AM, Duan Jiong wrote:
> This patch fixes coccinelle error regarding usage of IS_ERR and
> PTR_ERR instead of PTR_ERR_OR_ZERO.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
