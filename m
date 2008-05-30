Date: Fri, 30 May 2008 06:28:46 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 1/2] hugetlb: present information in sysfs
Message-ID: <20080530042846.GC25792@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.841211000@nick.local0.net> <20080529063915.GC11357@us.ibm.com> <20080530025846.GC6007@kroah.com> <20080530033748.GA25792@wotan.suse.de> <20080530042107.GA7946@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080530042107.GA7946@kroah.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Thu, May 29, 2008 at 09:21:07PM -0700, Greg KH wrote:
> On Fri, May 30, 2008 at 05:37:49AM +0200, Nick Piggin wrote:
> > 
> > Thanks Greg. Nish will be away for a few weeks but I'm picking up his patch
> > and so I can add the Documentation/ABI change.
> > 
> > I agree the interface looks nice, so thanks to everyone for the input and
> > discussion. A minor nit: is there any point specifying units in the
> > hugepages directory names? hugepages-64K hugepages-16M hugepages-16G?
> > 
> > Or perhaps for easier parsing, they could be the same unit but still
> > specificied? hugepages-64K hugepages-16384K etc?
> 
> I don't care, nothing is going to parse the directory names, they are
> pretty much fixed, right?  Just pick a unit and stick with it :)

I can imagine a cross platform app or library parsing them to find
eg. the largest one available that fits the required size and alignment.
Even within the same platform, there could be many different sizes
(eg. ia64).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
