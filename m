Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6873C6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:54:13 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id u110so147808110qge.3
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:54:13 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0106.outbound.protection.outlook.com. [157.55.234.106])
        by mx.google.com with ESMTPS id z23si9502884qka.91.2016.03.21.02.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 02:54:12 -0700 (PDT)
Subject: Re: [PATCH 0/5] userfaultfd: extension for non cooperative uffd usage
References: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <56EFC4F2.2050104@virtuozzo.com>
Date: Mon, 21 Mar 2016 12:54:58 +0300
MIME-Version: 1.0
In-Reply-To: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rapoport@il.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>

On 03/20/2016 03:42 PM, Mike Rapoport wrote:
> Hi,
> 
> This set is to address the issues that appear in userfaultfd usage
> scenarios when the task monitoring the uffd and the mm-owner do not 
> cooperate to each other on VM changes such as remaps, madvises and 
> fork()-s.
> 
> The pacthes are essentially the same as in the prevoious respin (1),
> they've just been rebased on the current tree.
> 
> [1] http://thread.gmane.org/gmane.linux.kernel.mm/132662

Thanks, Mike!

Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
