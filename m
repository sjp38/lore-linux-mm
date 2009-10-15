Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7D59D6B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 15:45:24 -0400 (EDT)
Date: Thu, 15 Oct 2009 12:45:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/9] swap_info: swap count continuations
Message-Id: <20091015124500.01f7f063.akpm@linux-foundation.org>
In-Reply-To: <20091015123024.21ca3ef7.kamezawa.hiroyu@jp.fujitsu.com>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
	<Pine.LNX.4.64.0910150153560.3291@sister.anvils>
	<20091015123024.21ca3ef7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, hongshin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009 12:30:24 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Is  array of "unsigned long" counter is bad ?  (too big?)

metoo!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
