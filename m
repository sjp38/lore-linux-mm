Subject: Re: Better pagecache statistics ?
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1133457315.21429.29.camel@localhost.localdomain>
References: <1133377029.27824.90.camel@localhost.localdomain>
	 <20051201152029.GA14499@dmt.cnet>
	 <1133452790.27824.117.camel@localhost.localdomain>
	 <1133453411.2853.67.camel@laptopd505.fenrus.org>
	 <20051201170850.GA16235@dmt.cnet>
	 <1133457315.21429.29.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 01 Dec 2005 18:21:39 +0100
Message-Id: <1133457700.2853.78.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-12-01 at 09:15 -0800, Badari Pulavarty wrote:
> > Most of the issues you mention are null if you move the stats
> > maintenance burden to userspace. 
> > 
> > The performance impact is also minimized since the hooks 
> > (read: overhead) can be loaded on-demand as needed.
> > 
> 
> The overhead is - going through each mapping/inode in the system
> and dumping out "nrpages" - to get per-file statistics. This is
> going to be expensive, need locking and there is no single list 
> we can traverse to get it. I am not sure how to do this.

and worse... you're going to need memory to store the results, either in
kernel or in userspace, and you don't know how much until you're done.
That memory is going to need to be allocated, which in turn changes the
vm state..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
