Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA30395
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 17:44:53 -0500
Date: Thu, 26 Feb 1998 22:44:08 GMT
Message-Id: <199802262244.WAA03924@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Fairness in love and swapping
In-Reply-To: <Pine.LNX.3.91.980226123303.26424F-100000@mirkwood.dummy.home>
References: <199802261103.MAA03115@boole.fs100.suse.de>
	<Pine.LNX.3.91.980226123303.26424F-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Dr. Werner Fink" <werner@suse.de>, sct@dcs.ed.ac.uk, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 26 Feb 1998 12:34:40 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> Without my mmap-age patch, page cache pages aren't aged
> at all... They're just freed whenever they weren't referenced
> since the last scan. The PAGE_AGE_VALUE is quite useless IMO
> (but I could be wrong, Stephen?).

They _are_ useful for mapped images such as binaries (which are swapped
out by vmscan.c, not filemap.c), but not for otherwise unused, pure
cached pages.

--Stephen
