Message-ID: <3CC371CE.1EE4E264@earthlink.net>
Date: Sun, 21 Apr 2002 20:13:34 -0600
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: Why *not* rmap, anyway?
References: <3CC33CDF.7F48A5B3@earthlink.net> <3051330941.1019409833@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> > I was just reading Bill's reply regaring rmap, and it
> > seems to me that rmap is the most obvious and clean
> > way to handle unmapping pages. So now I wonder why
> > it wasn't done that way from the beginning?
> 
> Because it costs something to maintain the reverse map.
> If the cost exceeds the benefit, it's not worth it. That's

Sure, but it's not obvious (is it?) that the rmap cost
exceeds the cost of scanning every process's virtual
address space looking for pages to unmap.

I'll have to look at the rmap patch and see. And
I gather that the *BSDs have always had reverse-
mappings, but thus far I haven't been able to
fathom the BSD code tree well enough to track down
on the VM code.

Thanks,

-- Joe
  Using open-source software: free.
  Pissing Bill Gates off: priceless.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
