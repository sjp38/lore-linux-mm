Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of
	physical pages backing it
From: Rohit Seth <rohitseth@google.com>
Reply-To: rohitseth@google.com
In-Reply-To: <20060609194236.4b997b9a.akpm@osdl.org>
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
	 <20060609194236.4b997b9a.akpm@osdl.org>
Content-Type: text/plain
Date: Mon, 12 Jun 2006 10:49:23 -0700
Message-Id: <1150134563.9576.25.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-06-09 at 19:42 -0700, Andrew Morton wrote:
> On Fri, 09 Jun 2006 18:33:55 -0700
> Rohit Seth <rohitseth@google.com> wrote:
> 
> > Below is a patch that adds number of physical pages that each vma is
> > using in a process.  Exporting this information to user space
> > using /proc/<pid>/maps interface.
> 
> Ouch, that's an awful lot of open-coded incs and decs.  Isn't there some
> more centralised place we can do this?
> 

I'll look into this.  Possibly combining it with mm counters.

> What locking protects vma.nphys (can we call this nr_present or something?)
> 

I'll need to use the same atomic counters as mm.   And Yes nr_present is
a better name.

> Will this patch do the right thing with weird vmas such as the gate vma and
> mmaps of device memory, etc?
> 

I think so.  (though strictly speaking those special vmas are less
interesting).  But final solution (if we do decide to implement this
counter) will address that.

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
