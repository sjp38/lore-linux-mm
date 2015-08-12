Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 12E656B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 01:24:03 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so6530905pac.3
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 22:24:02 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id rc13si7612648pdb.23.2015.08.11.22.23.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Aug 2015 22:24:00 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.vnet.ibm.com>;
	Wed, 12 Aug 2015 10:53:56 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id CE157394005C
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:53:54 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7C5NoK846268648
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:53:51 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7C5NoI2010377
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:53:52 +0530
Date: Wed, 12 Aug 2015 10:53:46 +0530
From: Bharata B Rao <bharata@linux.vnet.ibm.com>
Subject: Re: [Qemu-devel] [PATCH 19/23] userfaultfd: activate syscall
Message-ID: <20150812052346.GC4587@in.ibm.com>
Reply-To: bharata@linux.vnet.ibm.com
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-20-git-send-email-aarcange@redhat.com>
 <20150811100728.GB4587@in.ibm.com>
 <20150811134826.GI4520@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150811134826.GI4520@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, zhang.zhanghailiang@huawei.com, Pavel Emelyanov <xemul@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andres Lagar-Cavilla <andreslc@google.com>, Mel Gorman <mgorman@suse.de>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Feiner <pfeiner@google.com>

On Tue, Aug 11, 2015 at 03:48:26PM +0200, Andrea Arcangeli wrote:
> Hello Bharata,
> 
> On Tue, Aug 11, 2015 at 03:37:29PM +0530, Bharata B Rao wrote:
> > May be it is a bit late to bring this up, but I needed the following fix
> > to userfault21 branch of your git tree to compile on powerpc.
> 
> Not late, just in time. I increased the number of syscalls in earlier
> versions, it must have gotten lost during a rejecting rebase, sorry.
> 
> I applied it to my tree and it can be applied to -mm and linux-next,
> thanks!
> 
> The syscall for arm32 are also ready and on their way to the arm tree,
> the testsuite worked fine there. ppc also should work fine if you
> could confirm it'd be interesting, just beware that I got a typo in
> the testcase:

The testsuite passes on powerpc.

--------------------
running userfaultfd
--------------------
nr_pages: 2040, nr_pages_per_cpu: 170
bounces: 31, mode: rnd racing ver poll, userfaults: 80 43 23 23 15 16 12 1 2 96 13 128
bounces: 30, mode: racing ver poll, userfaults: 35 54 62 49 47 48 2 8 0 78 1 0
bounces: 29, mode: rnd ver poll, userfaults: 114 153 70 106 78 57 143 92 114 96 1 0
bounces: 28, mode: ver poll, userfaults: 96 81 5 45 83 19 98 28 1 145 23 2
bounces: 27, mode: rnd racing poll, userfaults: 54 65 60 54 45 49 1 2 1 2 71 20
bounces: 26, mode: racing poll, userfaults: 90 83 35 29 37 35 30 42 3 4 49 6
bounces: 25, mode: rnd poll, userfaults: 52 50 178 112 51 41 23 42 18 99 59 0
bounces: 24, mode: poll, userfaults: 136 101 83 260 84 29 16 88 1 6 160 57
bounces: 23, mode: rnd racing ver, userfaults: 141 197 158 183 39 49 3 52 8 3 6 0
bounces: 22, mode: racing ver, userfaults: 242 266 244 180 162 32 87 43 31 40 34 0
bounces: 21, mode: rnd ver, userfaults: 636 158 175 24 253 104 48 8 0 0 0 0
bounces: 20, mode: ver, userfaults: 531 204 225 117 129 107 11 143 76 31 1 0
bounces: 19, mode: rnd racing, userfaults: 303 169 225 145 59 219 37 0 0 0 0 0
bounces: 18, mode: racing, userfaults: 374 372 37 144 126 90 25 12 15 17 0 0
bounces: 17, mode: rnd, userfaults: 313 412 134 108 80 99 7 56 85 0 0 0
bounces: 16, mode:, userfaults: 431 58 87 167 120 113 98 60 14 8 48 0
bounces: 15, mode: rnd racing ver poll, userfaults: 41 40 25 28 37 24 0 0 0 0 180 75
bounces: 14, mode: racing ver poll, userfaults: 43 53 30 28 25 15 19 0 0 0 0 30
bounces: 13, mode: rnd ver poll, userfaults: 136 91 114 91 92 79 114 77 75 68 1 2
bounces: 12, mode: ver poll, userfaults: 92 120 114 76 153 75 132 157 83 81 10 1
bounces: 11, mode: rnd racing poll, userfaults: 50 72 69 52 53 48 46 59 57 51 37 1
bounces: 10, mode: racing poll, userfaults: 33 49 38 68 35 63 57 49 49 47 25 10
bounces: 9, mode: rnd poll, userfaults: 167 150 67 123 39 75 1 2 9 125 1 1
bounces: 8, mode: poll, userfaults: 147 102 20 87 5 27 118 14 104 40 21 28
bounces: 7, mode: rnd racing ver, userfaults: 305 254 208 74 59 96 36 14 11 7 4 5
bounces: 6, mode: racing ver, userfaults: 290 114 191 94 162 114 34 6 6 32 23 2
bounces: 5, mode: rnd ver, userfaults: 370 381 22 273 21 106 17 55 0 0 0 0
bounces: 4, mode: ver, userfaults: 328 279 179 191 74 86 95 15 13 10 0 0
bounces: 3, mode: rnd racing, userfaults: 222 215 164 70 5 20 179 0 34 3 0 0
bounces: 2, mode: racing, userfaults: 316 385 112 160 225 5 30 49 42 2 4 0
bounces: 1, mode: rnd, userfaults: 273 139 253 176 163 71 85 2 0 0 0 0
bounces: 0, mode:, userfaults: 165 212 633 13 24 66 24 27 15 0 10 1
[PASS]

Regards,
Bharata.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
