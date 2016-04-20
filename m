Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 20A396B026A
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 05:43:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e190so77479669pfe.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 02:43:42 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0128.outbound.protection.outlook.com. [104.47.2.128])
        by mx.google.com with ESMTPS id f85si3439405pff.157.2016.04.20.02.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Apr 2016 02:43:41 -0700 (PDT)
Subject: Re: [PATCH 0/5] userfaultfd: extension for non cooperative uffd usage
References: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <57174F90.7080109@virtuozzo.com>
Date: Wed, 20 Apr 2016 12:44:48 +0300
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

Hi, Andrea.

Hopefully one day after LSFMM is good time to try to get a bit of
your attention to this set :)

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
