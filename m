Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB9816B0339
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 05:36:12 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h200so985635itb.3
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 02:36:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o68sor265505iof.226.2018.01.03.02.36.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 02:36:11 -0800 (PST)
Date: Wed, 3 Jan 2018 16:06:06 +0530
From: Aishwarya Pant <aishpant@gmail.com>
Subject: Documentation: ksm: move sysfs interface to ABI
Message-ID: <20180103103605.GA23960@mordor.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org
Cc: Julia Lawall <Julia.Lawall@lip6.fr>, Greg KH <gregkh@linuxfoundation.org>

Hi

In Documentation/vm/ksm.txt, there is a description of the kernel samepage
merging sysfs interface and there also exists
Documentation/ABI/testing/sysfs-kernel-mm-ksm which is out of date.

Would it be useful to move out the interface from Documentation/vm/ksm.txt to
the ABI?

The ABI documentation format looks like the following:

What: (the full sysfs path of the attribute)
Date: (date of creation)
KernelVersion: (kernel version it first showed up in)
Contact: (primary contact)
Description: (long description on usage)

I am doing this in an exercise to move sysfs ABI interfaces (which are
documented) to their right place i.e. in Documentation/ABI along with the rest.

Aishwarya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
