Received: by nf-out-0910.google.com with SMTP id c2so1928630nfe
        for <linux-mm@kvack.org>; Sun, 26 Nov 2006 17:34:03 -0800 (PST)
Message-ID: <8bd0f97a0611261734i292a5c14s196ae037608c2c32@mail.gmail.com>
Date: Sun, 26 Nov 2006 20:34:02 -0500
From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: The VFS cache is not freed when there is not enough free memory to allocate
In-Reply-To: <1164192171.5968.186.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6d6a94c50611212351if1701ecx7b89b3fe79371554@mail.gmail.com>
	 <1164185036.5968.179.camel@twins>
	 <6d6a94c50611220202t1d076b4cye70dcdcc19f56e55@mail.gmail.com>
	 <1164192171.5968.186.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Aubrey <aubreylee@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On 11/22/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Yes it does that, but there is no guarantee that those 50MB have a
> single 1M contiguous region amongst them.

right ... the testcase posted is more to quickly illustrate the
problem ... the requested size doesnt really matter, what does matter
is that we cant seem to reclaim memory from the VFS cache in scenarios
where the VFS cache is eating a ton of memory and we need some more

another scenario is where an application is constantly reading data
from a cd, re-encoding it to mp3, and then writing it to disk.  the
VFS cache here quickly eats up the available memory.
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
