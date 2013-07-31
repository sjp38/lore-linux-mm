Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id A897A6B0032
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:50:14 -0400 (EDT)
Date: Wed, 31 Jul 2013 11:50:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/4] memcg: fix memcg resource limit overflow issues
Message-ID: <20130731095010.GA5012@dhcp22.suse.cz>
References: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
 <CAFj3OHX4WLaecyE_zFbnFKs9wrCWTq2eDAUDMxqPg8=TYt18gg@mail.gmail.com>
 <51F8D016.4090009@huawei.com>
 <51F8D0E1.4010007@huawei.com>
 <CAFj3OHUEVM+BtoYS8wbXRU42Q8_=1X5qaQm7QY8oBc=ONAdfOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFj3OHUEVM+BtoYS8wbXRU42Q8_=1X5qaQm7QY8oBc=ONAdfOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: Li Zefan <lizefan@huawei.com>, Qiang Huang <h.huangqiang@huawei.com>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sha Zhengju <handai.szj@taobao.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Jeff Liu <jeff.liu@oracle.com>

On Wed 31-07-13 17:39:43, Sha Zhengju wrote:
> I don't want to block the community, since they're urgent to the
> patches and Michal has already reviewed them just now, I won't be
> so caustic on it. I'm OK of letting the codes in under the rules of
> community.

Your s-o-b has been preserved which was sufficient for me, but
preserving the original From would be polity and sorry I have missed
that, I would have screamed as well. It should be added in the next
repost.

Qiang Huang s-o-b is appropriate as well as he has rebased and reposted
the series, though.

Anyway, I do not see any reason to postpone this series as it is a good
improvement.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
