Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA26966
	for <linux-mm@kvack.org>; Wed, 1 Jul 1998 05:24:05 -0400
Date: Wed, 1 Jul 1998 10:09:05 +0100
Message-Id: <199807010909.KAA00784@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Thread implementations...
In-Reply-To: <Pine.LNX.3.96dg4.980630122740.23907D-100000@twinlark.arctic.org>
References: <199806301310.OAA00911@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96dg4.980630122740.23907D-100000@twinlark.arctic.org>
Sender: owner-linux-mm@kvack.org
To: Dean Gaudet <dgaudet-list-linux-kernel@arctic.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, Christoph Rohland <hans-christoph.rohland@sap-ag.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 30 Jun 1998 12:35:35 -0700 (PDT), Dean Gaudet
<dgaudet-list-linux-kernel@arctic.org> said:

> On Tue, 30 Jun 1998, Stephen C. Tweedie wrote:

>> Not for very large files: the forget-behind is absolutely critical in
>> that case.

> I dunno why you're thinking of unmapping pages though...  But you do
> want them to be dropped from memory when appropriate.

We want to *physically* unmap them from the page tables.  You can't
evict the pages from cache if they are still physically mapped!

--Stephen
