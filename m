Date: Thu, 9 Sep 2004 10:23:32 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-ID: <20040909172332.GZ3106@holomorphy.com>
References: <cone.1094513660.210107.6110.502@pc.kolivas.org> <20040907000304.GA8083@logos.cnet> <20040907212051.GC3492@logos.cnet> <413F1518.7050608@sgi.com> <20040908165412.GB4284@logos.cnet> <413F5EE7.6050705@sgi.com> <20040908193036.GH4284@logos.cnet> <413FC8AC.7030707@sgi.com> <20040909030916.GR3106@holomorphy.com> <414065A8.20508@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <414065A8.20508@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Please log periodic snapshots of /proc/vmstat during runs on kernel
>> versions before and after major behavioral shifts.

On Thu, Sep 09, 2004 at 09:16:08AM -0500, Ray Bryant wrote:
> Attached is the output you requested for two kernel versions: 2.6.8.1-mm4 
> and 2.6.9-rc1-mm3 + the nrmap_patch (that patch didn't make much difference 
> so this should be good enough for comparison purposes, and it was the 
> kernel I had built.)
> Because there are so many parameters in /proc/vmstat, I had to split the
> output up (more or less arbitarily) into three files to get something you 
> could actually look at with an editor.  Even then it requires 100 columns 
> or so.

This will do fine. I'll examine these for anomalous maintenance of
statistics and/or operational variables used to drive page replacement.

Thanks.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
