Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28BC66B000A
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 16:17:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k21-v6so1830397ede.12
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 13:17:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hk1-v6si1784991ejb.149.2018.10.14.13.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Oct 2018 13:17:42 -0700 (PDT)
Subject: Re: [Bug 201377] New: Kernel BUG under memory pressure: unable to
 handle kernel NULL pointer dereference at 00000000000000f0
References: <bug-201377-27@https.bugzilla.kernel.org/>
 <20181012155533.2f15a8bb35103aa1fa87962e@linux-foundation.org>
 <20181012155641.b3a1610b4ddcd37e374115d4@linux-foundation.org>
 <9f77da23-2a46-29a5-6aa7-fe9e7cca1056@suse.cz>
 <555fbd1f-4ac9-0b58-dcd4-5dc4380ff7ca@suse.cz>
 <RO1P152MB14838EBA2F5ACD64A1CD3C3697FC0@RO1P152MB1483.LAMP152.PROD.OUTLOOK.COM>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <863182da-4302-07a5-7280-0c017561b7eb@suse.cz>
Date: Sun, 14 Oct 2018 22:14:57 +0200
MIME-Version: 1.0
In-Reply-To: <RO1P152MB14838EBA2F5ACD64A1CD3C3697FC0@RO1P152MB1483.LAMP152.PROD.OUTLOOK.COM>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Leonardo_Soares_M=c3=bcller?= <leozinho29_eu@hotmail.com>, Andrew Morton <akpm@linux-foundation.org>, "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Colascione <dancol@google.com>, Alexey Dobriyan <adobriyan@gmail.com>

On 10/14/18 8:07 PM, Leonardo Soares MA 1/4 ller wrote:
> This patch applied on 4.19-rc7 corrected the problem to me and the
> script is no longer triggering the kernel bug.

Great! Can we add your Tested-by: then?

> I completely skipped 4.18 because there were multiple regressions
> affecting my computer. 4.19-rc6 and 4.19-rc7 have most regressions fixed
> but then this issue appeared.
> 
> The first kernel version released I found with this problem is 4.18-rc4,

OK, that confirms the smaps_rollup problem is indeed older than my
rewrite. Unless it's a typo and you mean 4.19-rc4 since you "skipped 4.18".

> but bisecting between 4.18-rc3 and 4.18-rc4 failed: on boot there was
> one message starting with [UNSUPP] and with something about "Arbitrary
> File System".
> 
