Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 1C7956B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:52:26 -0400 (EDT)
Message-ID: <51F8D016.4090009@huawei.com>
Date: Wed, 31 Jul 2013 16:51:34 +0800
From: Qiang Huang <h.huangqiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] memcg: fix memcg resource limit overflow issues
References: <1375255885-10648-1-git-send-email-h.huangqiang@huawei.com> <CAFj3OHX4WLaecyE_zFbnFKs9wrCWTq2eDAUDMxqPg8=TYt18gg@mail.gmail.com>
In-Reply-To: <CAFj3OHX4WLaecyE_zFbnFKs9wrCWTq2eDAUDMxqPg8=TYt18gg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sha Zhengju <handai.szj@taobao.com>, lizefan@huawei.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Jeff Liu <jeff.liu@oracle.com>

On 2013/7/31 16:23, Sha Zhengju wrote:
> Hi list,
> 
> On Wed, Jul 31, 2013 at 3:31 PM, Qiang Huang <h.huangqiang@huawei.com> wrote:
>> This issue is first discussed in:
>> http://marc.info/?l=linux-mm&m=136574878704295&w=2
>>
>> Then a second version sent to:
>> http://marc.info/?l=linux-mm&m=136776855928310&w=2
>>
>> We contacted Sha a month ago, she seems have no time to deal with it
>> recently, but we quite need this patch. So I modified and resent it.
> 
> 
> No, I didn't receive any of YOUR message, only a engineer named Libo
> Chen from Huawei connected me recently. I don't approve you to resent
> them on behalf of me, and just before you send this you even don't
> send me a mail. Besides, after a rough look, I do not see any
> innovative ideas from yourself but just rework patches from my last
> version.
> So I'm strong against this patchset.

Sorry if this troubles you.
Libo Chen is my colleague, we work together, he sent an email to you on
25 June, to ask about this issue, you said you'll resent it soon, but it
didn't happen until now :(, and he asked again the other day and you didn't
reply. As we really need to fix this problem(and need it in upstream), so
I modified it and sent out.

I think split patches, rewrite changelogs and tests, they all kind of work
right? Of course, if you mind, I can change it, I just need this fix merged
to upstream ASAP.

So you want me rewrite this patchset and SOB only you or you want resent this
by yourself? I'm ok with both :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
