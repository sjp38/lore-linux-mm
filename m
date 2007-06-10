Date: Sun, 10 Jun 2007 19:32:21 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 15 of 16] limit reclaim if enough pages have been freed
Message-ID: <20070610173221.GB7443@v2.random>
References: <31ef5d0bf924fb47da14.1181332993@v2.random> <466C32F2.9000306@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <466C32F2.9000306@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 10, 2007 at 01:20:50PM -0400, Rik van Riel wrote:
> code simultaneously, all starting out at priority 12 and
> not freeing anything until they all get to much lower
> priorities.

BTW, this reminds me that I've been wondering if 2**12 is a too small
fraction of the lru to start the scan with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
