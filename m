Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 7A16C6B014C
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 11:05:50 -0400 (EDT)
Date: Mon, 11 Jun 2012 10:05:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5] slab/mempolicy: always use local policy from interrupt
 context
In-Reply-To: <1339234803-21106-1-git-send-email-tdmackey@twitter.com>
Message-ID: <alpine.DEB.2.00.1206111005290.1168@router.home>
References: <1338438844-5022-1-git-send-email-andi@firstfloor.org> <1339234803-21106-1-git-send-email-tdmackey@twitter.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Mackey <tdmackey@twitter.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, Andi Kleen <ak@linux.intel.com>, penberg@kernel.org

On Sat, 9 Jun 2012, David Mackey wrote:

> I believe the original mempolicy code did that in fact,
> so it's likely a regression.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
