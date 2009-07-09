Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5D45F6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:08:27 -0400 (EDT)
Message-ID: <4A5660CB.5080607@redhat.com>
Date: Thu, 09 Jul 2009 17:27:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
References: <c0e57d57-3f36-4405-b3f1-1a8c48089394@default>
In-Reply-To: <c0e57d57-3f36-4405-b3f1-1a8c48089394@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:

> I'm not saying either one is bad or good -- and I'm sure
> each can be adapted to approximately deliver the value
> of the other -- they are just approaching the same problem
> from different perspectives.

Indeed.  Tmem and auto-ballooning have a simple mechanism,
but the policy required to make it work right could well
be too complex to ever get right.

CMM2 has a more complex mechanism, but the policy is
absolutely trivial.

CMM2 and auto-ballooning seem to give about similar
performance gains on zSystem.

I suspect that for Xen and KVM, we'll want to choose
for the approach that has the simpler policy, because
relying on different versions of different operating
systems to all get the policy of auto-ballooning or
tmem right is likely to result in bad interactions
between guests and other intractable issues.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
