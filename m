Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA07193
	for <linux-mm@kvack.org>; Mon, 2 Mar 1998 17:37:43 -0500
Date: Mon, 2 Mar 1998 22:35:39 GMT
Message-Id: <199803022235.WAA03546@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Fairness in love and swapping
In-Reply-To: <Pine.LNX.3.91.980302171448.29405D-100000@mirkwood.dummy.home>
References: <199802271941.TAA01151@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.91.980302171448.29405D-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Dr. Werner Fink" <werner@suse.de>, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 2 Mar 1998 17:19:41 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> Nevertheless, the system seems to run smoother when the
> page-cache pages aren't thrown away immediately, but aged
> as normal pages are. Read-ahead pages _are_ sometimes
> freed before they're actually used, so in this case the
> system _will_ have to read them again. 

Absolutely.  The trouble is that

a) the kernel likes to keep reclaiming pages from a single source if
it is finding it easy to locate unused pages there, so when it starts
on the page cache it _can_ get over zealous in reaping those pages;
and

b) starting to find free pages from swap is inherently difficult due
to the initial age placed on pages.

I rather suspect with those patches that it's not simply the aging of
page cache pages which helps performance, but also the tuning of the
balance between page cache and data page reclamation.

--Stephen
