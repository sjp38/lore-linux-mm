Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id CF4E66B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 15:05:20 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id y10so686583wgg.29
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 12:05:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g13si25157471wiv.43.2014.07.03.12.05.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 12:05:19 -0700 (PDT)
Date: Thu, 3 Jul 2014 15:05:06 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting
 2MB limit (bug 79111)
Message-ID: <20140703190506.GA24683@redhat.com>
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
 <53B59CB5.9060004@linux.vnet.ibm.com>
 <CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
 <CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com>
 <53B5A343.4090402@linux.vnet.ibm.com>
 <CA+55aFyqK90YJkjtHR2QGFt4Mvn=mj8a4FkB_8nbTTj3=jp3NA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyqK90YJkjtHR2QGFt4Mvn=mj8a4FkB_8nbTTj3=jp3NA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 03, 2014 at 11:53:57AM -0700, Linus Torvalds wrote:
 > On Thu, Jul 3, 2014 at 11:38 AM, Raghavendra K T
 > <raghavendra.kt@linux.vnet.ibm.com> wrote:
 > >
 > > Okay, how about something like 256MB? I would be happy to send a patch
 > > for that change.
 > 
 > I'd like to see some performance numbers. I know at least Fedora uses
 > "readahead()" in the startup scripts, do we have any performance
 > numbers for that?

this got rolled up into systemd a while ago, so it's not just Fedora.

re: numbers, systemd-analyze and systemd-bootchart look like the way
to figure that out..
https://wiki.archlinux.org/index.php/Improve_boot_performance

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
