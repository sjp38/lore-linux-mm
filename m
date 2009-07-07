Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 477DB6B005A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 13:45:26 -0400 (EDT)
Message-ID: <4A538A34.7060101@redhat.com>
Date: Tue, 07 Jul 2009 13:47:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/4] (Take 2): tmem: Core API between kernel and tmem
References: <e5a93cf7-c24c-4bfe-bc4c-c24eb8e0290d@default>
In-Reply-To: <e5a93cf7-c24c-4bfe-bc4c-c24eb8e0290d@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:
> Tmem [PATCH 1/4] (Take 2): Core API between kernel and tmem

I like the cleanup of your patch series.

However, what remains is a fair bit of code.

It would be good to have performance numbers before
deciding whether or not to merge all this code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
