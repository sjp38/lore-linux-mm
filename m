Date: Wed, 23 Apr 2008 03:03:00 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080423010259.GA17572@wotan.suse.de>
References: <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422165602.GA29570@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Greg KH <gregkh@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 09:56:02AM -0700, Nishanth Aravamudan wrote:
> On 22.04.2008 [07:14:47 +0200], Nick Piggin wrote:
> 
> > So anyway, underneath that directory, we should have more
> > subdirectories grouping subsystems or sumilar functionality. We aren't
> > tuning node, but hugepages subsystem.
> > 
> > /sys/kernel/huge{tlb|pages}/
> > 
> > Under that directory could be global settings as well as per node
> > settings or subdirectories and so on. The layout should be similar to
> > /proc/sys/* IMO. Actually it should be much neater since we have some
> > hindsight, but unfortunately it is looking like it is actually messier
> > ;)
> 
> Well, that's where I start to get a little stymied. It seems odd to me
> to have some per-node information in one place and some in another,
> where the two are not even rooted at the same location, beyond both
> being in sysfs.

Why are nodes special? Why wouldn't you also group per-CPU information in
one place, for example?

Anyway, I'd argue that you wouldn't group either of those things primarily.
You would group by functionality first.

If you wanted to tweak or view your hugepages parameters, where do you
start? /sys/kernel/node is unintuitive; /sys/kernel/hugepages is easy.


> Perhaps, as I've mentioned elsewhere, we simply have
> symlinks underneath /sys/kernel/hugepages into
> /sys/devices/system/node/nodeX ... but the immediate ugliness I see
> there is either we duplicate the directories, or we symlink the

I don't like the idea of putting kernel implementation parameters in
/sys/devices/ (grey area for device drivers, perhaps).


> directories and there are now to paths into all the NUMA information,
> where one (/sys/kernel/hugepages/nodeX) seems like it should only have
> hugepage information.

But the idea of getting "all NUMA information" from one place just seems
wrong to me. Getting all *hardware* NUMA information from one place is
fine. But kernel implementation wise I think you are really interested in
subsystems *first*.

Just to demonstrate how badly "all NUMA information in one place"
generalises: you also then need a completely different place to store
global information for that subsystem, and a different place again to
store per-CPU information.

 
> I'd prefer hugepages to hugetlb, I think, but don't necessarily care one
> way or the other.

I'm fine with that. 


> > Let's really try to put some thought into new sysfs locations. Not
> > just will it work, but is it logical and will it work tomorrow...
> 
> I agree and that's why I keep sending out e-mails about it :) Perhaps I
> should prototype /sys/kernel/hugepages so we can see how it would look
> as a first step, and then decide given that layout how we want the
> per-node information to be presented?

Sure.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
