Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 759416B0027
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 04:03:46 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 16 Apr 2013 09:00:43 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id A825C17D8020
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 09:04:35 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3G83Vhp42860548
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 08:03:31 GMT
Received: from d06av05.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3G83e9P003791
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 02:03:40 -0600
Date: Tue, 16 Apr 2013 10:03:40 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [BUG][s390x] mm: system crashed
Message-ID: <20130416080340.GA23856@osiris>
References: <156480624.266924.1365995933797.JavaMail.root@redhat.com>
 <2068164110.268217.1365996520440.JavaMail.root@redhat.com>
 <20130415055627.GB4207@osiris>
 <516B9B57.6050308@redhat.com>
 <20130416075047.GA4184@osiris>
 <516D044B.3040300@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <516D044B.3040300@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, caiqian <caiqian@redhat.com>, Caspar Zhang <czhang@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Apr 16, 2013 at 03:56:59PM +0800, Simon Jeons wrote:
> Hi Heiko,
> >If you have some time, could you please repeat your test with the kernel
> >command line option " user_mode=home "?
> 
> What's the meaning of this command line? I can't find it in
> Documentation/kernel-parameters.txt/

It switches the architectural address space where kernel and user space
reside in.
We only recently switched the default address space for user space from
home space to primary space, since that's needed for kvm.
The user space runs in home space mode will be removed in the future; we
keep it currently as fallback, just in case something breaks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
