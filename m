Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 0CFC26B0068
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 10:32:06 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: [[PATCH -mm] 3/6] Fix the x86-64 page colouring code to take pgoff into account and use that code as the basis for a generic page colouring code.
Date: Mon, 18 Jun 2012 10:20:44 -0400
Message-Id: <1340029247-6949-4-git-send-email-riel@surriel.com>
In-Reply-To: <1340029247-6949-1-git-send-email-riel@surriel.com>
References: <1340029247-6949-1-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hnaz@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, knoel@redhat.com, Rik van Riel <riel@surriel.com>, Rik van Riel <riel@redhat.com>

<<< No Message Collected >>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
