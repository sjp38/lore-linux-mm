Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E61536B0169
	for <linux-mm@kvack.org>; Sat, 13 Aug 2011 02:58:24 -0400 (EDT)
Subject: Re: [PATCH 1/2] slub: extend slub_debug to handle multiple slabs
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <1312839019-17987-1-git-send-email-malchev@google.com>
References: <1312839019-17987-1-git-send-email-malchev@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Sat, 13 Aug 2011 09:58:21 +0300
Message-ID: <1313218701.29737.38.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Iliyan Malchev <malchev@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>

On Mon, 2011-08-08 at 14:30 -0700, Iliyan Malchev wrote:
> Extend the slub_debug syntax to "slub_debug=<flags>[,<slub>]*", where <slub>
> may contain an asterisk at the end.  For example, the following would poison
> all kmalloc slabs:
> 
> 	slub_debug=P,kmalloc*
> 
> and the following would apply the default flags to all kmalloc and all block IO
> slabs:
> 
> 	slub_debug=,bio*,kmalloc*
> 
> Signed-off-by: Iliyan Malchev <malchev@google.com>

Christoph, David, are you OK with the patches? They look reasonable to
me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
