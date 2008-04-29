Date: Tue, 29 Apr 2008 10:01:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
 [Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI]
In-Reply-To: <20080429164332.GA24967@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0804291001150.10847@schroedinger.engr.sgi.com>
References: <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com>
 <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com>
 <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com>
 <20080427051029.GA22858@suse.de> <Pine.LNX.4.64.0804281328300.31163@schroedinger.engr.sgi.com>
 <20080428205200.GA4386@us.ibm.com> <Pine.LNX.4.64.0804281427150.32083@schroedinger.engr.sgi.com>
 <20080429164332.GA24967@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Greg KH <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Apr 2008, Nishanth Aravamudan wrote:

> Ok, that was my impression. So on IA64, without further kernel
> modifications, we will always only have one hugepage size visible in
> /proc/meminfo and /sys/kernel/hugepages?

I am not aware of any work in progress. So yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
