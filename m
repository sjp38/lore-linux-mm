Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65E346B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:13:44 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id i9-v6so3109106ljg.21
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 09:13:44 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t20-v6si916596ljd.400.2018.07.20.09.13.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 09:13:42 -0700 (PDT)
Date: Fri, 20 Jul 2018 09:13:19 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180720161319.GB22645@castle.DHCP.thefacebook.com>
References: <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com>
 <20180713231630.GB17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com>
 <20180717194945.GM7193@dhcp22.suse.cz>
 <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807171329200.12251@chino.kir.corp.google.com>
 <20180717205221.GA19862@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807200126540.119737@chino.kir.corp.google.com>
 <20180720112131.GX72677@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180720112131.GX72677@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, gthelen@google.com

On Fri, Jul 20, 2018 at 04:21:31AM -0700, Tejun Heo wrote:
> Hello,
> 
> On Fri, Jul 20, 2018 at 01:30:00AM -0700, David Rientjes wrote:
> ...
> > process chosen for oom kill.  I know that you care about the latter.  My 
> > *only* suggestion was for the tunable to take a string instead of a 
> > boolean so it is extensible for future use.  This seems like something so 
> > trivial.
> 
> So, I'd much prefer it as boolean.  It's a fundamentally binary
> property, either handle the cgroup as a unit when chosen as oom victim
> or not, nothing more.  I don't see the (interface-wise) benefits of
> preparing for further oom policy extensions.  If that happens, it
> should be through a separate interface file.  The number of files
> isn't the most important criteria interface is designed on.
> 
> Roman, can you rename it tho to memory.oom.group?  That's how other
> interface files are scoped and it'd be better if we try to add further
> oom related interface files later.

Yes, sure, this looks good to me.

Thanks!
