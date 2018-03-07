Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6661B6B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 19:23:50 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u36so255609wrf.21
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 16:23:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g132si1369850wmd.211.2018.03.06.16.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 16:23:49 -0800 (PST)
Date: Tue, 6 Mar 2018 16:23:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 198913] New: Swapping slows to about 20% of expected speed
 when using multiple swap partitions on separate drives (striping).
Message-Id: <20180306162346.2fad560fa6957480fde918e2@linux-foundation.org>
In-Reply-To: <bug-198913-27@https.bugzilla.kernel.org/>
References: <bug-198913-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan@daniel-wynne-humphries.com
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 24 Feb 2018 03:56:38 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=198913
> 
>             Bug ID: 198913
>            Summary: Swapping slows to about 20% of expected speed when
>                     using multiple swap partitions on separate drives
>                     (striping).
> 
> ...
>
> Problems
> 1) Linux's swap striping on nine drives performs at only 19.5% of the speed of
> a memory-mapped file on a RAID 0 partition on the same nine drives.
> 2) Linux's swap striping performs best with exactly four swap partitions and
> performs almost as well with just three partitions.
> 

Well that's interesting, thanks.  Let's get this onto the mm
developers' mailing list and perhaps someone will have a theory.  And
perhaps Hugh will have a think about it when he returns to the fold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
