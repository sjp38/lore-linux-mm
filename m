Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA26349
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 08:29:16 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14091.20289.68799.79898@dukat.scot.redhat.com>
Date: Wed, 7 Apr 1999 13:27:45 +0100 (BST)
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904070007330.1141-100000@laser.random>
References: <14090.32072.214506.83641@dukat.scot.redhat.com>
	<Pine.LNX.4.05.9904070007330.1141-100000@laser.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Doug Ledford <dledford@redhat.com>, Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Mark Hemment <markhe@sco.COM>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 7 Apr 1999 00:27:21 +0200 (CEST), Andrea Arcangeli
<andrea@e-mind.com> said:

> It's not so obvious to me. I sure agree that an O(n) insertion/deletion is
> far too slow but a O(log(n)) for everything could be rasonable to me. And
> trees don't worry about unluky hash behavior.

Trees are O(log n) for insert/delete, with a high constant of
proportionality (ie. there can be quite a lot of work to be done even
for small log n).  Trees also occupy more memory per node.  Hashes are
O(1) for insert and delete, and are a _fast_ O(1).  The page cache needs
fast insert and delete.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
