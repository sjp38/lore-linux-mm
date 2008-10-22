Date: Wed, 22 Oct 2008 22:19:51 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081022201951.GS12825@one.firstfloor.org>
References: <20081021112137.GB12329@wotan.suse.de> <87mygxexev.fsf@basil.nowhere.org> <20081022103112.GA27862@wotan.suse.de> <20081022184624.GB31902@cynthia.pants.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081022184624.GB31902@cynthia.pants.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brad Boyer <flar@allandria.com>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Something that might be useful for this kind of testing is a block
> device that is just a map onto a real block device but allows the
> user to configure it to generate various errors. If we could set it

Both MD and DM have such injectors. That's not the problem. The problem
is the lack of a standard test suite that sets it all up and exercises
the relevant paths in the VM and FS.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
