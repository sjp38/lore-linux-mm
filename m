Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 417606B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:38:21 -0400 (EDT)
Date: Wed, 10 Apr 2013 20:38:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Rewrite the comment over migrate_pages() more
 comprehensibly
In-Reply-To: <20130410195919.17355.23052.stgit@srivatsabhat.in.ibm.com>
Message-ID: <0000013df5aba30b-b322bac3-7d1b-481d-bedc-33c3666fc627-000000@email.amazonses.com>
References: <20130410195919.17355.23052.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On Thu, 11 Apr 2013, Srivatsa S. Bhat wrote:

> The comment over migrate_pages() looks quite weird, and makes it hard
> to grasp what it is trying to say. Rewrite it more comprehensibly.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
