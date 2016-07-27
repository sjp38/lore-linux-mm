Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2BAF6B0261
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 05:21:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so12544897wmz.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 02:21:16 -0700 (PDT)
Received: from rs07.intra2net.com (rs07.intra2net.com. [85.214.138.66])
        by mx.google.com with ESMTPS id c67si14957029wma.125.2016.07.27.02.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 02:21:15 -0700 (PDT)
From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Re: Re: [Bug 64121] New: [BISECTED] "mm" performance regression updating from 3.2 to 3.3
Date: Wed, 27 Jul 2016 11:21:12 +0200
Message-ID: <6826483.YLAvyNmrHx@storm>
In-Reply-To: <1650204.9z6KOJWgNh@storm>
References: <bug-64121-27@https.bugzilla.kernel.org/> <b3219832-110d-2b74-5ba9-694ab30589f0@suse.cz> <1650204.9z6KOJWgNh@storm>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Wednesday, 27. July 2016 11:18:36 Thomas Jarosch wrote:
> It might be related to memory fragmentation of low memory due to the
> inode cache, the mail server has over 1.400.000 millions files.

1.400.000 files of course. Millions would be a bit much :)

Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
