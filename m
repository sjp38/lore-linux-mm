Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C50926B004D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 21:41:47 -0400 (EDT)
Received: by qyk15 with SMTP id 15so4989345qyk.12
        for <linux-mm@kvack.org>; Mon, 30 Mar 2009 18:42:26 -0700 (PDT)
Message-ID: <49D174FC.80900@codemonkey.ws>
Date: Mon, 30 Mar 2009 20:42:20 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com>
In-Reply-To: <1238457560-7613-1-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> I am sending another seires of patchs for kvm kernel and kvm-userspace
> that would allow users of kvm to test ksm with it.
> The kvm patchs would apply to Avi git tree.
>   
Any reason to not take these through upstream QEMU instead of 
kvm-userspace?  In principle, I don't see anything that would prevent 
normal QEMU from almost making use of this functionality.  That would 
make it one less thing to eventually have to merge...

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
