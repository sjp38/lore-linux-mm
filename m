Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 475816B004A
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 05:47:27 -0400 (EDT)
Date: Sat, 14 Apr 2012 17:42:22 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: page-writeback.c: local functions should not be
 exposed globally
Message-ID: <20120414094222.GA19710@localhost>
References: <201204121344.20613.hartleys@visionengravers.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201204121344.20613.hartleys@visionengravers.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Apr 12, 2012 at 01:44:20PM -0700, H Hartley Sweeten wrote:
> The function global_dirtyable_memory is only referenced in this file and
> should be marked static to prevent it from being exposed globally.
> 
> This quiets the sparse warning:
> 
> warning: symbol 'global_dirtyable_memory' was not declared. Should it be static?
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied, thanks!

Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
