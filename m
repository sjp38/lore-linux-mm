Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7F06B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:40:24 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q192so42388353iod.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 08:40:24 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id o123si5013880ita.65.2016.10.19.08.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 08:40:23 -0700 (PDT)
Date: Wed, 19 Oct 2016 10:40:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [4.9-rc1] Unable to handle kernel paging request
In-Reply-To: <CAC1QiQHeviJA_bCDSgOqpX03nvMJE8J3h+=1vSj9BJDExTKz+A@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1610191039330.4555@east.gentwo.org>
References: <CAC1QiQHeviJA_bCDSgOqpX03nvMJE8J3h+=1vSj9BJDExTKz+A@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryan Chan <ryan.chan105@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 19 Oct 2016, Ryan Chan wrote:

> Hi all,
> The following  message appeared during bootup. May I know if this a known
> issue? I did not meet this problem in 4.8-rcx,
> My desktop becomes unstable after bootup now

Please specify slub_debug on the kernel command line and rerun the test.
That should yield debugging output pointing at the issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
