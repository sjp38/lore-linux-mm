From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC 18/22] sh: Use generic show_mem()
Date: Thu, 03 Apr 2008 15:08:39 +0200
Message-ID: <87ej9nozl4.fsf@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
	<12071690311447-git-send-email-hannes@saeurebad.de>
	<20080403114124.GA25523@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757221AbYDCNI7@vger.kernel.org>
In-Reply-To: <20080403114124.GA25523@linux-sh.org> (Paul Mundt's message of
	"Thu, 3 Apr 2008 20:41:24 +0900")
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

Hi Paul,

Paul Mundt <lethal@linux-sh.org> writes:

> On Wed, Apr 02, 2008 at 10:40:24PM +0200, Johannes Weiner wrote:
>> -	printk(KERN_INFO "Total of %ld pages in page table cache\n",
>> -	       quicklist_total_size());
>> -}
>> -
>
> NACK. The quicklists are also absent from the generic implementation.
> Doing things generically is nice and all, but please do not go around
> removing all of the different implementations and consolidating on the
> simplest point of commonality you could come up with. Either combine
> everything in to a generic show_mem() that doesn't sacrifice
> functionality, or only convert the platforms that are identical.

Sorry, I made it an RFC because I was not quite sure if the generic pfn
walker is valid on all affected architectures.  If it is okay, I will
send a patch-set meant for application that does not miss any output.

Thanks,

	Hannes
