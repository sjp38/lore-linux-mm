Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 878496B0038
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 11:08:49 -0400 (EDT)
Date: Tue, 30 Jul 2013 08:08:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-Id: <20130730080810.9a0a2d71.akpm@linux-foundation.org>
In-Reply-To: <51F7D1F0.20309@intel.com>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
	<20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
	<20130730074531.GA10584@dhcp22.suse.cz>
	<20130730012544.2f33ebf6.akpm@linux-foundation.org>
	<20130730125525.GB15847@dhcp22.suse.cz>
	<51F7D1F0.20309@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

On Tue, 30 Jul 2013 07:47:12 -0700 Dave Hansen <dave.hansen@intel.com> wrote:

> On 07/30/2013 05:55 AM, Michal Hocko wrote:
> >> > If we add another flag in the future it can use bit 3?
> > What if we get crazy and need more of them?
> 
> I really hate using bits for these kinds of interfaces.  I'm forgetful
> and never remember which bit is which, and they're possible to run out of.
> 
> I'm not saying do it now, but we can switch over to:
> 
> 	echo 'slab|pagecache' > drop_caches
> or
> 	echo 'quiet|slab' > drop_caches
> 
> any time we want and still have compatibility with the existing bitwise
> interface.

	/bin/drop_caches "slab|pagecache"

That we always insist on doing such things in the kernel instead is
exhibit #1 in Why We Suck.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
