Received: from lrcsun15.epfl.ch (almesber@lrcsun15.epfl.ch [128.178.156.77])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA17525
	for <linux-mm@kvack.org>; Thu, 22 Oct 1998 05:54:32 -0400
From: Werner Almesberger <almesber@lrc.di.epfl.ch>
Message-Id: <199810220948.LAA06921@lrcsun15.epfl.ch>
Subject: Re: MM with fragmented memory
Date: Thu, 22 Oct 1998 11:48:26 +0200 (MET DST)
In-Reply-To: <Pine.LNX.3.96.981022112124.365A-100000@mirkwood.dummy.home> from "Rik van Riel" at Oct 22, 98 11:25:32 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@phys.uu.nl
Cc: linux-mm@kvack.org, linux-7110@redhat.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> linux-kernel replaced by linux-mm, since that is where the
> MM folks hang around and linux-kernel is busy enough as it
> is...

Ah, thanks !

>>  - allocations from start_mem and end_mem are each limited to a total of
>>    512kB
> 
> Allocations are limited to 128kB already.

Are you sure this limit also applies to linear allocations, i.e.
    my_huge_buffer = start_mem;
    start_mem += 5*1024*1024;
?

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, DI-ICA,EPFL,CH   werner.almesberger@lrc.di.epfl.ch /
/_IN_R_131__Tel_+41_21_693_6621__Fax_+41_21_693_6610_____________________/
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
