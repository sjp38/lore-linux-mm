Date: Thu, 13 Nov 2003 21:07:30 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.6.0-test9-mm3
Message-ID: <3210000.1068786449@[10.10.2.4]>
In-Reply-To: <20031112233002.436f5d0c.akpm@osdl.org>
References: <20031112233002.436f5d0c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> - Several ext2 and ext3 allocator fixes.  These need serious testing on big
>   SMP.

Survives kernbench and SDET on ext2 at least on 16-way. I'll try ext3
later.

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
