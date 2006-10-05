Subject: Re: Free memory level in 2.6.16?
From: Steve Bergman <sbergman@rueb.com>
In-Reply-To: <p73k63ezg3y.fsf@verdi.suse.de>
References: <1160034527.23009.7.camel@localhost>
	 <p73k63ezg3y.fsf@verdi.suse.de>
Content-Type: text/plain
Date: Thu, 05 Oct 2006 15:41:19 -0500
Message-Id: <1160080879.29452.24.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-10-05 at 22:01 +0200, Andi Kleen wrote:

> 
> You could play with /proc/sys/vm/lowmem_reserve_ratio but must
> likely some defaults need tweaking.

Hmmm, after a bit of googling and a download of 2.6.18, it seems that
documentation on lowmem_reserve_ratio is still on the todo list.

cat /proc/sys/vm/lowmem_reserve_ratio 

gives me "256 256 32" on the system in question.  Can someone give me a
quick rundown of what this means?

Thanks,
Steve Bergman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
