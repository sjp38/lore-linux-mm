Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A7B7D6B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 17:01:51 -0400 (EDT)
Message-ID: <4C6AF8B9.3010000@redhat.com>
Date: Tue, 17 Aug 2010 17:01:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] transparent hugepage sysfs meminfo
References: <20100803135615.GG6071@random.random> <alpine.DEB.2.00.1008171343570.972@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1008171343570.972@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 08/17/2010 04:56 PM, David Rientjes wrote:
> Add hugepage statistics to per-node sysfs meminfo
>
> Cc: Rik van Riel<riel@redhat.com>
> Signed-off-by: David Rientjes<rientjes@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
