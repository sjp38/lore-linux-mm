Date: Sun, 20 Apr 2008 23:06:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
In-Reply-To: <20080420022159.GA14037@suse.de>
Message-ID: <Pine.LNX.4.64.0804202305470.13872@schroedinger.engr.sgi.com>
References: <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com>
 <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de>
 <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com>
 <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com>
 <20080417233615.GA24508@us.ibm.com> <Pine.LNX.4.64.0804171639340.15173@schroedinger.engr.sgi.com>
 <20080420022159.GA14037@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 19 Apr 2008, Greg KH wrote:

> > That violation is replicated in /proc/meminfo /proc/vmstat etc etc.
> 
> Those are /proc files, not sysfs files :)

Hmmm.. Maybe we need to have /proc/node<x>/meminfo etc that replicates the 
/proc content for each node? Otherwise this cannot be symmetric because 
the different mount points have different requirements on how the output 
should look like.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
