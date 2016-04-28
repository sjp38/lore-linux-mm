Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1B66B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:03:26 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id c189so38607657vkb.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:03:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p29si4285790qki.199.2016.04.28.01.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 01:03:25 -0700 (PDT)
Date: Thu, 28 Apr 2016 09:03:20 +0100
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: post-copy is broken?
Message-ID: <20160428080319.GA2267@work-vm>
References: <20160415134233.GG2229@work-vm>
 <20160415152330.GB3376@node.shutemov.name>
 <20160415163448.GJ2229@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E04181101@shsmsx102.ccr.corp.intel.com>
 <20160418095528.GD2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0418115C@shsmsx102.ccr.corp.intel.com>
 <20160418101555.GE2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E041813A6@shsmsx102.ccr.corp.intel.com>
 <20160427144739.GF10120@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041877A3@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E041877A3@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

* Li, Liang Z (liang.z.li@intel.com) wrote:

> 
> I have test the patch, guest doesn't crash anymore, I think the issue is fixed. Thanks!

Great!  Thanks for reporting it.

Dave
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
