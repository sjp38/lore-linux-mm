Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 7CCB56B004D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 06:22:24 -0500 (EST)
Date: Tue, 4 Dec 2012 12:22:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH 2/3] memcg: disable pages allocation for swap cgroup
 on system booting up
Message-ID: <20121204112222.GJ31319@dhcp22.suse.cz>
References: <50BDB5E0.7030906@oracle.com>
 <50BDB5FB.6080707@oracle.com>
 <20121204111721.GB1343@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121204111721.GB1343@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>

On Tue 04-12-12 12:17:21, Michal Hocko wrote:
> On Tue 04-12-12 16:36:11, Jeff Liu wrote:
> > - Disable pages allocation for swap cgroup at system boot up stage.
> > - Perform page allocation if there have child memcg alive, because the user
> >   might disabled one/more swap files/partitions for some reason.
> > - Introduce a couple of helpers to deal with page allocation/free for swap cgroup.
> > - Introduce a new static variable to indicate the status of child memcg create/remove.
> 
> This approach doesn't work (unless I missed something). See bellow.

Wait a second I have missed that ctrl->map is already initialized.
Will get back to you...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
