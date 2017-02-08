Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02C5028089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 11:25:38 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id 96so79909781uaq.7
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 08:25:37 -0800 (PST)
Received: from mail-vk0-x22e.google.com (mail-vk0-x22e.google.com. [2607:f8b0:400c:c05::22e])
        by mx.google.com with ESMTPS id p15si2421679vkp.82.2017.02.08.08.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 08:25:37 -0800 (PST)
Received: by mail-vk0-x22e.google.com with SMTP id t8so104550030vke.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 08:25:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170207210651.GB30506@linux.vnet.ibm.com>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <20170207210651.GB30506@linux.vnet.ibm.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 8 Feb 2017 08:25:16 -0800
Message-ID: <CALCETrWA9vXktpw=56CoMhoqPQ6qSJbptUSTEeaW3vRCbVTvig@mail.gmail.com>
Subject: Re: PCID review?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 7, 2017 at 1:06 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Tue, Feb 07, 2017 at 10:56:59AM -0800, Andy Lutomirski wrote:
>> Quite a few people have expressed interest in enabling PCID on (x86)
>> Linux.  Here's the code:
>>
>> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid
>>
>> The main hold-up is that the code needs to be reviewed very carefully.
>> It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
>> entries using PCID" ought to be looked at carefully to make sure the
>> locking is right, but there are plenty of other ways this this could
>> all break.
>>
>> Anyone want to take a look or maybe scare up some other reviewers?
>> (Kees, you seemed *really* excited about getting this in.)
>
> Cool!
>
> So I can drop 61ec4c556b0d "rcu: Maintain special bits at bottom of
> ->dynticks counter", correct?

Nope.  That's a different optimization.  If you consider that patch
ready, want to email me, the dynticks folks, and linux-mm as a
reminder?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
