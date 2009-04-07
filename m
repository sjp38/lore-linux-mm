Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 102CC5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 15:35:48 -0400 (EDT)
Date: Tue, 7 Apr 2009 21:38:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/16] POISON: Intro
Message-ID: <20090407193834.GV17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407191300.GA10768@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090407191300.GA10768@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, Russ Anderson <rja@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 02:13:00PM -0500, Robin Holt wrote:
> How does this overlap with the bad page quarantine that ia64 uses
> following an MCA?

It's much more comprehensive than what ia64 has, mostly due to 
differing requirements. It also doesn't limit itself to user
mapped anonymous pages only.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
