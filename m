Date: Sat, 17 May 2003 12:49:48 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [RFC][PATCH] vm_operation to avoid pagefault/inval race
Message-Id: <20030517124948.6394ded6.akpm@digeo.com>
In-Reply-To: <200305172021.56773.phillips@arcor.de>
References: <200305172021.56773.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: paulmck@us.ibm.com, hch@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@arcor.de> wrote:
>
> and the only problem is, we have to change pretty well every 
>  filesystem in and out of tree.

But it's only a one-liner per fs.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
