Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6F1E36B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:19:46 -0400 (EDT)
Date: Thu, 11 Apr 2013 14:19:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] pagemap: Introduce the /proc/PID/pagemap2 file
Message-Id: <20130411141944.dc17b3b1c78132eedec06aa6@linux-foundation.org>
In-Reply-To: <51669EA5.20209@parallels.com>
References: <51669E5F.4000801@parallels.com>
	<51669EA5.20209@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 11 Apr 2013 15:29:41 +0400 Pavel Emelyanov <xemul@parallels.com> wrote:

> This file is the same as the pagemap one, but shows entries with bits
> 55-60 being zero (reserved for future use). Next patch will occupy one
> of them.

I'm not understanding the motivation for this.  What does the current
/proc/pid/pagemap have in those bit positions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
