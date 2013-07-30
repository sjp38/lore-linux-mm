Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 362BB6B0033
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:54:10 -0400 (EDT)
Date: Tue, 30 Jul 2013 16:54:05 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH resend] drop_caches: add some documentation and info
 message
Message-ID: <20130730145405.GA23365@pd.tnic>
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
 <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
 <20130730074531.GA10584@dhcp22.suse.cz>
 <20130730012544.2f33ebf6.akpm@linux-foundation.org>
 <20130730125525.GB15847@dhcp22.suse.cz>
 <51F7D1F0.20309@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <51F7D1F0.20309@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>

On Tue, Jul 30, 2013 at 07:47:12AM -0700, Dave Hansen wrote:
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

Hohum, definitely a nice idea at a first glance. And when you cat
drop_caches, it could show you what all those commands mean and how you
can issue them, i.e. allowed syntax etc.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
