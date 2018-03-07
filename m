Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B4D0F6B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 19:58:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l14so241300pgn.21
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 16:58:02 -0800 (PST)
Received: from MTA-08-3.privateemail.com (mta-08-3.privateemail.com. [198.54.127.61])
        by mx.google.com with ESMTPS id l14si10619202pgc.615.2018.03.06.16.58.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 16:58:01 -0800 (PST)
Message-ID: <1520384279.1885.2.camel@daniel-wynne-humphries.com>
Subject: Re: [Bug 198913] New: Swapping slows to about 20% of expected speed
 when using multiple swap partitions on separate drives (striping).
From: Dan <dan@daniel-wynne-humphries.com>
Date: Tue, 06 Mar 2018 16:57:59 -0800
In-Reply-To: <20180306162346.2fad560fa6957480fde918e2@linux-foundation.org>
References: <bug-198913-27@https.bugzilla.kernel.org/>
	 <20180306162346.2fad560fa6957480fde918e2@linux-foundation.org>
Content-Type: multipart/alternative; boundary="=-+tbatxcqrL6Eq0eeJfXD"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>


--=-+tbatxcqrL6Eq0eeJfXD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

On Tue, 2018-03-06 at 16:23 -0800, Andrew Morton wrote:
> (switched to email.A A Please respond via emailed reply-to-all, not via
> the
> bugzilla web interface).
> 
> On Sat, 24 Feb 2018 03:56:38 +0000 bugzilla-daemon@bugzilla.kernel.or
> g wrote:
> 
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=198913
> > 
> > A A A A A A A A A A A A Bug ID: 198913
> > A A A A A A A A A A A Summary: Swapping slows to about 20% of expected speed
> > when
> > A A A A A A A A A A A A A A A A A A A A using multiple swap partitions on separate
> > drives
> > A A A A A A A A A A A A A A A A A A A A (striping).
> > 
> > ...
> > 
> > Problems
> > 1) Linux's swap striping on nine drives performs at only 19.5% of
> > the speed of
> > a memory-mapped file on a RAID 0 partition on the same nine drives.
> > 2) Linux's swap striping performs best with exactly four swap
> > partitions and
> > performs almost as well with just three partitions.
> > 
> Well that's interesting, thanks.A A Let's get this onto the mm
> developers' mailing list and perhaps someone will have a theory.A A And
> perhaps Hugh will have a think about it when he returns to the fold.
Thanks, if let me know if you need me to run some test code or
something.

--=-+tbatxcqrL6Eq0eeJfXD
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: 7bit

<html><head></head><body><div>On Tue, 2018-03-06 at 16:23 -0800, Andrew Morton wrote:</div><blockquote type="cite"><pre>(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 24 Feb 2018 03:56:38 +0000 <a href="mailto:bugzilla-daemon@bugzilla.kernel.org">bugzilla-daemon@bugzilla.kernel.org</a> wrote:

<blockquote type="cite">
<a href="https://bugzilla.kernel.org/show_bug.cgi?id=198913">https://bugzilla.kernel.org/show_bug.cgi?id=198913</a>

            Bug ID: 198913
           Summary: Swapping slows to about 20% of expected speed when
                    using multiple swap partitions on separate drives
                    (striping).

...

Problems
1) Linux's swap striping on nine drives performs at only 19.5% of the speed of
a memory-mapped file on a RAID 0 partition on the same nine drives.
2) Linux's swap striping performs best with exactly four swap partitions and
performs almost as well with just three partitions.

</blockquote>

Well that's interesting, thanks.  Let's get this onto the mm
developers' mailing list and perhaps someone will have a theory.  And
perhaps Hugh will have a think about it when he returns to the fold.
</pre></blockquote><div><br></div><div>Thanks, if let me know if you need me to run some test code or something.</div><blockquote type="cite"><pre>
</pre></blockquote></body></html>
--=-+tbatxcqrL6Eq0eeJfXD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
