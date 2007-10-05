Date: Fri, 5 Oct 2007 12:17:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch]Documentation/vm/slabinfo.c: clean up this code
In-Reply-To: <20071005124614.GD12498@hacking>
Message-ID: <Pine.LNX.4.64.0710051216250.17345@schroedinger.engr.sgi.com>
References: <20071005124614.GD12498@hacking>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Oct 2007, WANG Cong wrote:

> 
> This patch does the following cleanups for Documentation/vm/slabinfo.c:
> 
> 	- Fix two memory leaks;

For user space code? Memory will be released as soon as the program 
terminates.

> 	- Constify some char pointers;
> 	- Use snprintf instead of sprintf in case of buffer overflow;
> 	- Fix some indentations;
> 	- Other little improvements.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
