Subject: Re: 2.6.0-test7-mm1 4G/4G hanging at boot
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <20031017111955.439d01c8.rddunlap@osdl.org>
References: <20031017111955.439d01c8.rddunlap@osdl.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 17 Oct 2003 14:03:44 -0500
Message-Id: <1066417426.19236.3316.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, mingo@redhat.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2003-10-17 at 13:19, Randy.Dunlap wrote:
> I'm seeing this at boot:
> 
> Checking if this processor honours the WP bit even in supervisor mode...
> 
> then I wait for 1-2 minutes and hit the power button.
> This is on an IBM dual-proc P4 (non-HT) with 1 GB of RAM.
> 
> Has anyone else seen this?  Suggestions or fixes?
> 
This was a problem a while back with a bad check fixed by this patch:
http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test3/2.6.0-test3-mm2/broken-out/4g4g-do_page_fault-cleanup.patch
I can't seem to find that it slipped back in anywhere but the problem
sounds identical (minus an error message about invalid kernel-mode
pagefault before).

-Paul Larson


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
