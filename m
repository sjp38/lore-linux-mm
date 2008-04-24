Date: Thu, 24 Apr 2008 09:13:52 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080424071352.GB14543@wotan.suse.de>
References: <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com> <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423183252.GA10548@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Greg KH <gregkh@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 11:32:52AM -0700, Nishanth Aravamudan wrote:
> 
> So, I think, we pretty much agree on how things should be:
> 
> Direct translation of the current sysctl:
> 
> /sys/kernel/hugepages/nr_hugepages
>                       nr_overcommit_hugepages
> 
> Adding multiple pools:
> 
> /sys/kernel/hugepages/nr_hugepages -> nr_hugepages_${default_size}
>                       nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
>                       nr_hugepages_${default_size}
>                       nr_overcommit_hugepages_${default_size}
>                       nr_hugepages_${other_size1}
>                       nr_overcommit_hugepages_${other_size2}
> 
> Adding per-node control:
> 
> /sys/kernel/hugepages/nr_hugepages -> nr_hugepages_${default_size}
>                       nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
>                       nr_hugepages_${default_size}
>                       nr_overcommit_hugepages_${default_size}
>                       nr_hugepages_${other_size1}
>                       nr_overcommit_hugepages_${other_size2}
>                       nodeX/nr_hugepages -> nr_hugepages_${default_size}
>                             nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
>                             nr_hugepages_${default_size}
>                             nr_overcommit_hugepages_${default_size}
>                             nr_hugepages_${other_size1}
>                             nr_overcommit_hugepages_${other_size2}
> 
> How does that look? Does anyone have any problems with such an
> arrangement?

Looks pretty good. I would personally lean toward subdirectories for
hstates. Pros are that it would be a little easier to navigate from
the shell, and maybe more regular to program for.

You could possibly have hugepages_default symlink as well to one of
the directories of your choice. This could be used by apps which do
not specify exactly what size they want...

I don't know, just ideas.

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
