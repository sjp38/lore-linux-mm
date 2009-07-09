Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8E26A6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 18:26:00 -0400 (EDT)
Message-ID: <4A567310.5@redhat.com>
Date: Thu, 09 Jul 2009 18:45:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
References: <7cb22078-f200-45e3-a265-10cce2ae8224@default>
In-Reply-To: <7cb22078-f200-45e3-a265-10cce2ae8224@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:

> But this means that either the content of that page must have been
> preserved somewhere or the discard fault handler has sufficient
> information to go back and get the content from the source (e.g.
> the filesystem).  Or am I misunderstanding?

The latter.  Only pages which can be fetched from
source again are marked as volatile.

> But IMHO this is a corollary of the fundamental difference.  CMM2's
> is more the "VMware" approach which is that OS's should never have
> to be modified to run in a virtual environment.

Actually, the CMM2 mechanism is quite invasive in
the guest operating system's kernel.

> ( I don't see why CMM2 provides more flexibility.

I don't think anyone is arguing that.  One thing
that people have argued is that CMM2 can be more
efficient, and easier to get the policy right in
the face of multiple guest operating systems.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
