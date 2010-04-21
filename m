Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5DFB56B01F5
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 20:54:46 -0400 (EDT)
Message-ID: <4BCE4D34.5050200@cn.fujitsu.com>
Date: Wed, 21 Apr 2010 08:56:20 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: repost - RFC [Patch] Remove "please try 'cgroup_disable=memory'
 option if you don't want memory cgroups" printk at boot time.
References: <1271773587.28748.134.camel@dhcp-100-19-198.bos.redhat.com> <20100421092502.787371b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100421092502.787371b5.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> My biggest concern is that we don't have man(5) cgroup as other file systems.
> If we have man(5), the best place for this kind of information will be it.
> I think most of users will never see kernel-parameter.txt ..
> 
> If usual distros are shipped with man(5) cgroup, I agree removing
> this in upstream.
> (We have man pages for libcgroup but not man(5) for cgroup file system.)
> 
> I'm sorry if I don't notice that the latest man package has cgroup section.
> 

We have a man-page for cpuset, which was written by Paul Jackson,
the author of cpuset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
