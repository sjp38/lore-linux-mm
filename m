Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 4344A6B0032
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:23:52 -0400 (EDT)
Received: by mail-bk0-f44.google.com with SMTP id mz10so130039bkb.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:23:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
References: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com>
Date: Wed, 31 Jul 2013 16:23:50 +0800
Message-ID: <CAFj3OHX4WLaecyE_zFbnFKs9wrCWTq2eDAUDMxqPg8=TYt18gg@mail.gmail.com>
Subject: Re: [PATCH 0/4] memcg: fix memcg resource limit overflow issues
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sha Zhengju <handai.szj@taobao.com>, lizefan@huawei.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Jeff Liu <jeff.liu@oracle.com>

Hi list,

On Wed, Jul 31, 2013 at 3:31 PM, Qiang Huang <h.huangqiang@huawei.com> wrote:
> This issue is first discussed in:
> http://marc.info/?l=linux-mm&m=136574878704295&w=2
>
> Then a second version sent to:
> http://marc.info/?l=linux-mm&m=136776855928310&w=2
>
> We contacted Sha a month ago, she seems have no time to deal with it
> recently, but we quite need this patch. So I modified and resent it.


No, I didn't receive any of YOUR message, only a engineer named Libo
Chen from Huawei connected me recently. I don't approve you to resent
them on behalf of me, and just before you send this you even don't
send me a mail. Besides, after a rough look, I do not see any
innovative ideas from yourself but just rework patches from my last
version.
So I'm strong against this patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
