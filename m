Date: Mon, 28 Apr 2008 13:31:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
 [Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI]
In-Reply-To: <20080427051029.GA22858@suse.de>
Message-ID: <Pine.LNX.4.64.0804281328300.31163@schroedinger.engr.sgi.com>
References: <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com>
 <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com>
 <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com>
 <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com>
 <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com>
 <20080427051029.GA22858@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 26 Apr 2008, Greg KH wrote:

> Also, why use a "units" here, just always use the lowest unit, and
> userspace can convert from kB to GB if needed.

Additional complications will come about because IA64 supports 
varying hugetlb sizes from 4kb to 1GB.

Also we would at some point like to add support for 1TB hugepages (that 
may depend on the presence of a special device that handles these).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
