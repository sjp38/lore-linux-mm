Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E2CD96B00BB
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 12:36:06 -0400 (EDT)
Date: Mon, 18 Oct 2010 11:36:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] Add vzalloc shortcut
In-Reply-To: <20101016043331.GA3177@darkstar>
Message-ID: <alpine.DEB.2.00.1010181135290.2092@router.home>
References: <20101016043331.GA3177@darkstar>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Oct 2010, Dave Young wrote:

> Add vzalloc for convinience of vmalloc-then-memset-zero case

Reviewed-by: Christoph Lameter <cl@linux.com>

Wish we would also have vzalloc_node() but I guess that can wait.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
