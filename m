Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F2236B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 07:39:16 -0400 (EDT)
Received: by pxi5 with SMTP id 5so2182720pxi.14
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 04:39:15 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 5 Oct 2010 13:39:14 +0200
Message-ID: <AANLkTik34ZKasZMMpx4wD71k+RPccGLvAi1Cwe5UwZpj@mail.gmail.com>
Subject: [PATCH] pramfs: Persistent and protected RAM filesystem
From: Marco Stornelli <marco.stornelli@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-embedded@vger.kernel.org, linux-fsdevel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

after a lot of improvement, test, bug fix and new features, it's the
moment for third round with the kernel community to submit PRAMFS for
mainline. First of all, I have to say thanks to Tim Bird and CELF to
actively support the project.

Since the last review (June 2009) a lot of things are changed:

- removed any reference of BKL
- fixed the endianess for the fs layout
- added support for extended attributes, ACLs and security labels
- moved out any pte manipulations from fs and inserted them in mm
- implemented the new truncate convention
- fixed problems with 64bit archs

...and much more. Complete "story" in the ChangeLog inserted in the
documentation file.

Since the patch is long, you can download and review the patch from
the project site: http:\\pramfs.sourceforge.net. The patch version is
1.2.1 for kernel 2.6.36.
In addition, in the web site tech page, you can find a lot of
information about implementation, technical details, benchemarking and
so on.

Regards,

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
