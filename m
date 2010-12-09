Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3E7FD6B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 20:53:48 -0500 (EST)
Date: Thu, 9 Dec 2010 08:23:02 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [1/7,v8] NUMA Hotplug Emulator: documentation
Message-ID: <20101209002302.GB5798@shaohui>
References: <20101207010033.280301752@intel.com>
 <20101207010139.681125359@intel.com>
 <20101207182420.GA2038@mgebm.net>
 <20101207232000.GA5353@shaohui>
 <20101208181644.GA2152@mgebm.net>
 <alpine.DEB.2.00.1012081315040.15658@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012081315040.15658@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Eric B Munson <emunson@mgebm.net>, Shaohui Zheng <shaohui.zheng@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, dave@linux.vnet.ibm.com, Greg Kroah-Hartman <gregkh@suse.de>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 01:16:10PM -0800, David Rientjes wrote:
> On Wed, 8 Dec 2010, Eric B Munson wrote:
> 
> > Shaohui,
> > 
> > I was able to online a cpu to node 0 successfully.  My problem was that I did
> > not take the cpu offline before I released it.  Everything looks to be working
> > for me.
> > 
> 
> I think it should fail more gracefully than triggering WARN_ON()s because 
> of duplicate sysfs dentries though, right?

Yes, we should do more checking on the return value, the duplicate dentries can
be avoided.  

Another solution: force user to offline the cpu before we do cpu release.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
