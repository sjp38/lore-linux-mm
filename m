Date: Fri, 10 Dec 2004 13:38:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: pfault V12 : correction to tasklist rss
Message-Id: <20041210133859.2443a856.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0412102054190.32422-100000@localhost.localdomain>
References: <Pine.LNX.4.58.0412101150490.9169@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0412102054190.32422-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: clameter@sgi.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> > We have no  real way of establishing the ownership of shared pages
>  > anyways. Its counted when allocated. But the page may live on afterwards
>  > in another process and then not be accounted for although its only user is
>  > the new process.
> 
>  I didn't understand that bit.

We did lose some accounting accuracy when the pagetable walk and the big
tasklist walks were removed.  Bill would probably have more details.  Given
that the code as it stood was a complete showstopper, the tradeoff seemed
reasonable.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
