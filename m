Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of
	physical pages backing it
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1149903235.31417.84.camel@galaxy.corp.google.com>
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
Content-Type: text/plain
Date: Sun, 11 Jun 2006 18:09:02 +0200
Message-Id: <1150042142.3131.82.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rohitseth@google.com
Cc: Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-06-09 at 18:33 -0700, Rohit Seth wrote:
> Below is a patch that adds number of physical pages that each vma is
> using in a process.  Exporting this information to user space
> using /proc/<pid>/maps interface.

is it really worth bloating the vma struct for this? there are quite a
few workloads that have a gazilion vma's, and this patch adds both
memory usage and cache pressure to those workloads...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
