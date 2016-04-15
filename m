Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 986EA6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 18:19:47 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t184so104252291qkh.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 15:19:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 188si36004766qhj.38.2016.04.15.15.19.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 15:19:47 -0700 (PDT)
Date: Fri, 15 Apr 2016 18:19:43 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: post-copy is broken?
Message-ID: <20160415221943.GJ9976@redhat.com>
References: <F2CBF3009FA73547804AE4C663CAB28E0417EEE4@shsmsx102.ccr.corp.intel.com>
 <20160413080545.GA2270@work-vm>
 <20160413114103.GB2270@work-vm>
 <20160413125053.GC2270@work-vm>
 <20160413205132.GG26364@redhat.com>
 <20160414123441.GF2252@work-vm>
 <20160414162230.GC9976@redhat.com>
 <20160415125236.GA3376@node.shutemov.name>
 <20160415134233.GG2229@work-vm>
 <20160415152330.GB3376@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160415152330.GB3376@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, kirill.shutemov@linux.intel.com, "Li, Liang Z" <liang.z.li@intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, linux-mm@kvack.org

On Fri, Apr 15, 2016 at 06:23:30PM +0300, Kirill A. Shutemov wrote:
> The same here. Freshly booted machine with 64GiB ram. I've checked
> /proc/vmstat: huge pages were allocated

I tried the test in a loop and I can't reproduce it here.

Tested with gcc 4.9.3 and glibc 2.21 and glibc 2.22 so far,
qemu&kernel/KVM latest upstream (4.6-rc3..).

You can run this in between each invocation to guarantee all memory is
backed by THP (no need of reboot):

# echo 3 >/proc/sys/vm/drop_caches
# echo >/proc/sys/vm/compact_memory

4.5 kernel built with gcc 5.3.1 run on a older userland worked fine
too.

Next thing to test would be if there's something wrong with qemu built
with gcc 5.3.1 if run on top of a 4.4 kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
