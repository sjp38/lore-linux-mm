Date: Tue, 18 Mar 2008 18:20:45 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-ID: <20080318172045.GI11966@one.firstfloor.org>
References: <20080318209.039112899@firstfloor.org> <20080318003620.d84efb95.akpm@linux-foundation.org> <20080318141828.GD11966@one.firstfloor.org> <20080318095715.27120788.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080318095715.27120788.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> What's the permission problem?  executable-but-not-readable files?  Could

Not writable. 

> be handled by passing your request to a suitable-privileged server process,
> I guess.

Yes it could, but i dont even want to thi nk about all the issues of
doing such an interface. It is basically an microkernelish approach.
I prefer monolithic simplicity.

e.g. i am pretty sure your user space implementation would be far
more complicated than a nicely streamlined kernel implementation. 
And I am really not a friend of unnecessary complexity. In the end
complexity hurts you, no matter if it is in ring 3 or ring 0.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
