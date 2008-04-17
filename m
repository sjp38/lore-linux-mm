Date: Thu, 17 Apr 2008 16:22:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
In-Reply-To: <20080417231617.GA18815@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com>
 <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com>
 <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de>
 <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com>
 <20080417231617.GA18815@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Greg KH <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Apr 2008, Nishanth Aravamudan wrote:

> > Do you see a particular more-sysfs-way here, Greg?
> 
> So I've received no comments yet? Perhaps I should leave things the way
> they are (per-node files in /sys/devices/system/node) and add
> nr_hugepages to /sys/kernel?

The strange location of the node directories has always irked me.
> 
> Do we want to put it in a subdirectory of /sys/kernel? What should the
> subdir be called? "hugetlb" (refers to the implementation?) or
> "hugepages"?

How about:

/sys/kernel/node<nr>/<node specific setting/status files> ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
