Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5DE3F6B0082
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 17:54:07 -0400 (EDT)
Message-ID: <4A3814E0.9080607@redhat.com>
Date: Tue, 16 Jun 2009 17:55:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm: make swap token dummies static inlines
References: <Pine.LNX.4.64.0906162152250.12770@sister.anvils> <1245189037-22961-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1245189037-22961-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:
> Make use of the compiler's typechecking on !CONFIG_SWAP as well.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
