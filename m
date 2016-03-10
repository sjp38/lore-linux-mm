Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 727466B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 02:57:49 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id y89so63937524qge.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 23:57:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z203si2542245qka.44.2016.03.09.23.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 23:57:48 -0800 (PST)
Date: Thu, 10 Mar 2016 13:27:28 +0530
From: Amit Shah <amit.shah@redhat.com>
Subject: Re: [RFC qemu 0/4] A PV solution for live migration optimization
Message-ID: <20160310075728.GB4678@grmbl.mre>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160308111343.GM15443@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A7E3@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E0414A7E3@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "quintela@redhat.com" <quintela@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>

On (Thu) 10 Mar 2016 [07:44:19], Li, Liang Z wrote:
> 
> Hi Amit,
> 
>  Could provide more information on how to use virtio-serial to exchange data?  Thread , Wiki or code are all OK. 
>  I have not find some useful information yet.

See this commit in the Linux sources:

108fc82596e3b66b819df9d28c1ebbc9ab5de14c

that adds a way to send guest trace data over to the host.  I think
that's the most relevant to your use-case.  However, you'll have to
add an in-kernel user of virtio-serial (like the virtio-console code
-- the code that deals with tty and hvc currently).  There's no other
non-tty user right now, and this is the right kind of use-case to add
one for!

For many other (userspace) use-cases, see the qemu-guest-agent in the
qemu sources.

The API is documented in the wiki:

http://www.linux-kvm.org/page/Virtio-serial_API

and the feature pages have some information that may help as well:

https://fedoraproject.org/wiki/Features/VirtioSerial

There are some links in here too:

http://log.amitshah.net/2010/09/communication-between-guests-and-hosts/

Hope this helps.


		Amit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
