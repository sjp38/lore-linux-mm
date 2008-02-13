Date: Wed, 13 Feb 2008 14:34:07 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 9941] New: Zone "Normal" missing in /proc/zoneinfo
Message-ID: <20080213143406.GA1328@csn.ul.ie>
References: <bug-9941-27@http.bugzilla.kernel.org/> <20080212100623.4fd6cf85.akpm@linux-foundation.org> <e2e108260802122339j3b861e74vf7b72a34747dcade@mail.gmail.com> <20080212234522.24bed8c1.akpm@linux-foundation.org> <20080213115225.GB4007@csn.ul.ie> <e2e108260802130545u3086fbecn2793aab64b895a74@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e2e108260802130545u3086fbecn2793aab64b895a74@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bart Van Assche <bart.vanassche@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (13/02/08 14:45), Bart Van Assche didst pronounce:
> On Feb 13, 2008 12:52 PM,  <bugme-daemon@bugzilla.kernel.org> wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=9941
> >
> > On x86_64 (which is what it is according to the config), machines with less
> > than 4GB of RAM will have no ZONE_NORMAL. This machine appears to have 2GB. I
> > don't see the problem as such because it's like PPC64 only having ZONE_DMA
> > (ZONE_NORMAL exists but it is always empty).
> >
> > > Mel, is this, uh, normal?
> > >
> >
> > On x86_64, it is.
> 
> Both tests were performed with the kernel compiled for x86_64 and were
> run on the same system. I was surprised to see a difference in the
> zoneinfo between 2.6.24 and 2.6.24.2 kernels.

You are not the only one. I boot-tested an x86_64 machine with 3GB of
RAM which is as close as was available to yours and I got

root@elm3a188:~# uname -r
2.6.24-autokern1
root@elm3a188:~# free -m                  
             total       used       free     shared    buffers cached
Mem:          2988         83       2904          0          2 28
-/+ buffers/cache:         52       2935
Swap:        15633          0      15633
root@elm3a188:~# grep zone /proc/zoneinfo 
Node 0, zone      DMA
Node 0, zone    DMA32

No sign of ZONE_NORMAL there.

> But if I understand you
> correctly then the 2.6.24.2 behavior is the only correct behavior ?
> 

Yes. You should not be seeing a Normal zone unless you have > 4GB of
RAM unless for some really strange reason your physical memory was
placed above the 4GB mark which is possibly but unlikely. Could you post
the dmesg -s 1000000 of 2.6.24 and its .config just in case please?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
