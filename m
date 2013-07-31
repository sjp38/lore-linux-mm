Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 7751D6B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 06:04:32 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id jg9so166920bkc.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2013 03:04:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130731095010.GA5012@dhcp22.suse.cz>
References: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
	<CAFj3OHX4WLaecyE_zFbnFKs9wrCWTq2eDAUDMxqPg8=TYt18gg@mail.gmail.com>
	<51F8D016.4090009@huawei.com>
	<51F8D0E1.4010007@huawei.com>
	<CAFj3OHUEVM+BtoYS8wbXRU42Q8_=1X5qaQm7QY8oBc=ONAdfOA@mail.gmail.com>
	<20130731095010.GA5012@dhcp22.suse.cz>
Date: Wed, 31 Jul 2013 18:04:30 +0800
Message-ID: <CAFj3OHWOKn3NdbBzhKq5iCoB8BaiZVuf=VauLuB=NthyuDgZdQ@mail.gmail.com>
Subject: Re: [PATCH 0/4] memcg: fix memcg resource limit overflow issues
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Qiang Huang <h.huangqiang@huawei.com>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sha Zhengju <handai.szj@taobao.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Jeff Liu <jeff.liu@oracle.com>

On Wed, Jul 31, 2013 at 5:50 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Wed 31-07-13 17:39:43, Sha Zhengju wrote:
>> I don't want to block the community, since they're urgent to the
>> patches and Michal has already reviewed them just now, I won't be
>> so caustic on it. I'm OK of letting the codes in under the rules of
>> community.
>
> Your s-o-b has been preserved which was sufficient for me, but
> preserving the original From would be polity and sorry I have missed
> that, I would have screamed as well. It should be added in the next
> repost.

Thanks for the support.

> Qiang Huang s-o-b is appropriate as well as he has rebased and reposted
> the series, though.
>
> Anyway, I do not see any reason to postpone this series as it is a good
> improvement.
>

Yeah, I thought the problem it tries to solve is rarely encountered
when I sent it last time. But now I also glad to see it merged soon.



Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
