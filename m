Received: from fred.muc.de (noidentity@ns2057.munich.netsurf.de [195.180.232.57])
	by kvack.org (8.8.7/8.8.7) with SMTP id JAA07241
	for <linux-mm@kvack.org>; Fri, 30 Apr 1999 09:57:42 -0400
Message-ID: <19970101162919.58637@fred.muc.de>
Date: Wed, 1 Jan 1997 16:29:19 +0100
From: ak@muc.de
Subject: Re: Hello
References: <001901be9324$66ddcbf0$c80c17ac@clmsdev.local> <14120.65431.754233.47675@dukat.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <14120.65431.754233.47675@dukat.scot.redhat.com>; from Stephen C. Tweedie on Fri, Apr 30, 1999 at 02:55:51AM +0200
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>, Manfred Spraul <masp0008@stud.uni-sb.de>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, "James E. King, III" <jking@ariessys.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 30, 1999 at 02:55:51AM +0200, Stephen C. Tweedie wrote:
> Hi,
> 
> On Fri, 30 Apr 1999 18:12:21 +0200, "Manfred Spraul"
> <masp0008@stud.uni-sb.de> said:
> 
> > * I haven't yet read the new Xeon page table extentions,
> >   but perhaps we could support up to 64 GB memory without changing the
> >   rest of the OS   (Intel could write such a driver for Windows NT,
> >   I'm sure this is possible for Linux, too).
> 
> NT's VLM support only gives you access to the high memory if you use a
> special API.  We plan on supporting clean access to all of physical
> memory quite transparently for Linux, without any such restrictions.

Not even the restriction that a single process cannot use more than 
4GB-something?


-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
