Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A10BD6B0038
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 14:37:52 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v184so162216113pgv.6
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 11:37:52 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id w28si4953303pge.203.2017.02.07.11.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 11:37:51 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id y143so9896057pfb.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 11:37:51 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: Re: PCID review?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
Date: Tue, 7 Feb 2017 11:37:49 -0800
Content-Transfer-Encoding: 7bit
Message-Id: <1FEF704E-915D-4A2B-987A-593B8EABE961@gmail.com>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Just a small question: should try_to_unmap_flush() work with these changes? 

> On Feb 7, 2017, at 10:56 AM, Andy Lutomirski <luto@kernel.org> wrote:
> 
> Quite a few people have expressed interest in enabling PCID on (x86)
> Linux.  Here's the code:
> 
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid
> 
> The main hold-up is that the code needs to be reviewed very carefully.
> It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
> entries using PCID" ought to be looked at carefully to make sure the
> locking is right, but there are plenty of other ways this this could
> all break.
> 
> Anyone want to take a look or maybe scare up some other reviewers?
> (Kees, you seemed *really* excited about getting this in.)
> 
> --Andy
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
