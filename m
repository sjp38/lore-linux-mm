Received: from bbmail1.unisys.com (192-63-2005.unisys.com [192.63.200.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA07554
	for <linux-mm@kvack.org>; Wed, 17 Dec 1997 23:19:12 -0500
Received: from felix.tulblr.unisys.com (felix.tulblr.unisys.com [163.122.1.109])
	by bbmail1.unisys.com (8.8.5/8.8.5) with SMTP id EAA16810
	for <linux-mm@kvack.org>; Thu, 18 Dec 1997 04:12:50 GMT
Date: Thu, 18 Dec 1997 09:46:58 +0500 (IST)
From: Gaurish R Dalvi <gaurishr@tulblr.unisys.com>
Subject: zombies ....
In-Reply-To: <Pine.LNX.3.91.971216124819.15838B-100000@mirkwood.dummy.home>
Message-ID: <Pine.SV4.3.95.971218094449.17067A-100000@felix>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!
	A small doubt.
	Thing is according to books, a zombie has released all its memory
etc. but clogs up a system as the kernel has to maintain its return state.

	How can you make the system release the zombie totally. ( i.e. it
shud not appear in ps command listsing even.).
