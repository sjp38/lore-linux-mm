Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id B54796B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:13:29 -0400 (EDT)
Received: by dadq36 with SMTP id q36so145348dad.8
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:13:29 -0700 (PDT)
Date: Thu, 26 Apr 2012 15:13:24 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/2] decrement static keys on real destroy time
Message-ID: <20120426221324.GE27486@google.com>
References: <1335475463-25167-1-git-send-email-glommer@parallels.com>
 <1335475463-25167-3-git-send-email-glommer@parallels.com>
 <20120426213916.GD27486@google.com>
 <4F99C50D.6070503@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F99C50D.6070503@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, netdev@vger.kernel.org, Li Zefan <lizefan@huawei.com>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, devel@openvz.org

Hello, Glauber.

On Thu, Apr 26, 2012 at 06:58:37PM -0300, Glauber Costa wrote:
> At first I though that we could get rid of all this complication by
> calling stop machine from the static_branch API. This would all
> magically go away. I actually even tried it.
> 
> However, reading the code for other architectures (other than x86),
> I found that they usually rely on the fixed instruction size to just
> patch an instruction atomically and go home happy.
> 
> Using stop machine and the like would slow them down considerably.
> Not only slow down the static branch update (which is acceptable),
> but everybody else (which is horrible). It seemed to defeat the
> purpose of static branches a bit.
> 
> The other users of static branches seems to be fine coping with the
> fact that in cases with multiple-sites, they will spread in time.

No, what I mean is that why can't you do about the same mutexed
activated inside static_key API function instead of requiring every
user to worry about the function returning asynchronously.
ie. synchronize inside static_key API instead of in the callers.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
