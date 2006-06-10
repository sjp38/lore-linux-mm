Date: Fri, 9 Jun 2006 19:42:36 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of
 physical pages backing it
Message-Id: <20060609194236.4b997b9a.akpm@osdl.org>
In-Reply-To: <1149903235.31417.84.camel@galaxy.corp.google.com>
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rohitseth@google.com
Cc: Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 09 Jun 2006 18:33:55 -0700
Rohit Seth <rohitseth@google.com> wrote:

> Below is a patch that adds number of physical pages that each vma is
> using in a process.  Exporting this information to user space
> using /proc/<pid>/maps interface.

Ouch, that's an awful lot of open-coded incs and decs.  Isn't there some
more centralised place we can do this?

What locking protects vma.nphys (can we call this nr_present or something?)

Will this patch do the right thing with weird vmas such as the gate vma and
mmaps of device memory, etc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
