Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18943
	for <linux-mm@kvack.org>; Mon, 23 Mar 1998 18:05:52 -0500
Date: Mon, 23 Mar 1998 21:20:06 GMT
Message-Id: <199803232120.VAA02077@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: __free_page() and free_pages() - Differences?
In-Reply-To: <Pine.SUN.3.95.980322184553.3977Z-100000@Kabini>
References: <Pine.SUN.3.95.980322184553.3977Z-100000@Kabini>
Sender: owner-linux-mm@kvack.org
To: Chirayu Patel <chirayu@wipro.tcpn.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 22 Mar 1998 18:57:28 +0530 (GMT+0530), Chirayu Patel
<chirayu@wipro.tcpn.com> said:

> Hi ,
> I am having trouble understanding the difference between 
> the __free_page function and free_pages function in page_alloc.c

They are identical functions with different calling conventions.  When
we are freeing a page, we often have a page struct already in hand, so
__free_page is an alternative way of freeing a page which avoids the
unnecessary page map lookup.

--Stephen
