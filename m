Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id B94706B0078
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 15:29:51 -0500 (EST)
Date: Thu, 8 Nov 2012 12:29:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Add a test program for variable page sizes in
 mmap/shmget
Message-Id: <20121108122950.4ce5fe18.akpm@linux-foundation.org>
In-Reply-To: <1352406063-3566-1-git-send-email-andi@firstfloor.org>
References: <1352406063-3566-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Thu,  8 Nov 2012 12:21:03 -0800
Andi Kleen <andi@firstfloor.org> wrote:

> Not hooked up to the harness so far, because it usually needs
> special boot options for 1GB pages.

Can we detect that situation within thuge-gen.c?  Emit a polite
message then exit(0).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
