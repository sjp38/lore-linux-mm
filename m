Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 656766B005A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 13:26:14 -0400 (EDT)
Message-ID: <4A5385AD.9000800@redhat.com>
Date: Tue, 07 Jul 2009 13:28:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
References: <482d25af-01eb-4c2a-9b1d-bdaf4020ce88@default>
In-Reply-To: <482d25af-01eb-4c2a-9b1d-bdaf4020ce88@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:

> "Preswap" IS persistent, but for various reasons may not always be
> available for use, again due to factors that may not be visible to the
> kernel (but, briefly, if the kernel is being "good" and has shared its
> resources nicely, then it will be able to use preswap, else it will not).
> Once a page is put, a get on the page will always succeed. 

What happens when all of the free memory on a system
has been consumed by preswap by a few guests?

Will the system be unable to start another guest,
or is there some way to free the preswap memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
