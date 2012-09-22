Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A2B596B005A
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 08:40:36 -0400 (EDT)
Date: Sat, 22 Sep 2012 20:40:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/5] Remove file_ra_state from arguments of
 count_history_pages.
Message-ID: <20120922124028.GA15962@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <e7275bef84867156b343ea3d558c4f669d1bc8b9.1348309711.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7275bef84867156b343ea3d558c4f669d1bc8b9.1348309711.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghu.prabhu13@gmail.com
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Sat, Sep 22, 2012 at 04:03:12PM +0530, raghu.prabhu13@gmail.com wrote:
> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> 
> count_history_pages doesn't require readahead state to calculate the offset from history.
> 
> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>

Acked-by: Fengguang Wu <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
