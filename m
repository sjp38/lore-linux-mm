Received: by el-out-1112.google.com with SMTP id z25so16207ele.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2008 05:45:18 -0800 (PST)
Message-ID: <e2e108260802130545u3086fbecn2793aab64b895a74@mail.gmail.com>
Date: Wed, 13 Feb 2008 14:45:17 +0100
From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: [Bug 9941] New: Zone "Normal" missing in /proc/zoneinfo
In-Reply-To: <20080213115225.GB4007@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <bug-9941-27@http.bugzilla.kernel.org/>
	 <20080212100623.4fd6cf85.akpm@linux-foundation.org>
	 <e2e108260802122339j3b861e74vf7b72a34747dcade@mail.gmail.com>
	 <20080212234522.24bed8c1.akpm@linux-foundation.org>
	 <20080213115225.GB4007@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Feb 13, 2008 12:52 PM,  <bugme-daemon@bugzilla.kernel.org> wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=9941
>
> On x86_64 (which is what it is according to the config), machines with less
> than 4GB of RAM will have no ZONE_NORMAL. This machine appears to have 2GB. I
> don't see the problem as such because it's like PPC64 only having ZONE_DMA
> (ZONE_NORMAL exists but it is always empty).
>
> > Mel, is this, uh, normal?
> >
>
> On x86_64, it is.

Both tests were performed with the kernel compiled for x86_64 and were
run on the same system. I was surprised to see a difference in the
zoneinfo between 2.6.24 and 2.6.24.2 kernels. But if I understand you
correctly then the 2.6.24.2 behavior is the only correct behavior ?

Bart Van Assche.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
