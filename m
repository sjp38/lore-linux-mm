Received: by rn-out-0910.google.com with SMTP id v46so84765rnb.14
        for <linux-mm@kvack.org>; Wed, 13 Feb 2008 07:32:24 -0800 (PST)
Message-ID: <e2e108260802130732k2fdb69dckf60dd64353fb9dc7@mail.gmail.com>
Date: Wed, 13 Feb 2008 16:32:23 +0100
From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: [Bug 9941] New: Zone "Normal" missing in /proc/zoneinfo
In-Reply-To: <20080213143406.GA1328@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <bug-9941-27@http.bugzilla.kernel.org/>
	 <20080212100623.4fd6cf85.akpm@linux-foundation.org>
	 <e2e108260802122339j3b861e74vf7b72a34747dcade@mail.gmail.com>
	 <20080212234522.24bed8c1.akpm@linux-foundation.org>
	 <20080213115225.GB4007@csn.ul.ie>
	 <e2e108260802130545u3086fbecn2793aab64b895a74@mail.gmail.com>
	 <20080213143406.GA1328@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Feb 13, 2008 3:34 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> Yes. You should not be seeing a Normal zone unless you have > 4GB of
> RAM unless for some really strange reason your physical memory was
> placed above the 4GB mark which is possibly but unlikely. Could you post
> the dmesg -s 1000000 of 2.6.24 and its .config just in case please?

Update: after rebooting into 2.6.24 I get now the same results with
2.6.24 and 2.6.24.2:

$ uname -a
Linux INF012 2.6.24 #1 SMP Wed Feb 13 16:16:07 CET 2008 x86_64 GNU/Linux
$ grep zone /proc/zoneinfo
Node 0, zone      DMA
Node 0, zone    DMA32

The output I included in the original bug report was probably from
another system with 2.6.24 that is running here, a system with 4 GB
memory instead of 2 GB. Sorry for the confusion I created.

Bart Van Assche.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
