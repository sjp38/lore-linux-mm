Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 19B116B0078
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 17:25:09 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bj1so14339567pad.5
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:25:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hl7si420106pac.62.2015.02.12.14.25.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 14:25:08 -0800 (PST)
Date: Thu, 12 Feb 2015 14:25:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND 0/3] memory_hotplug: hyperv: fix deadlock between
 memory adding and onlining
Message-Id: <20150212142506.09b427a9128a3a3b1ded36a4@linux-foundation.org>
In-Reply-To: <4323296.ObXCUgVR2I@vostro.rjw.lan>
References: <1423736634-338-1-git-send-email-vkuznets@redhat.com>
	<5256328.ZVnrTeLrH1@vostro.rjw.lan>
	<BY2PR0301MB0711D005F3C78EBFE56A2CD5A0220@BY2PR0301MB0711.namprd03.prod.outlook.com>
	<4323296.ObXCUgVR2I@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: KY Srinivasan <kys@microsoft.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 12 Feb 2015 23:43:17 +0100 "Rafael J. Wysocki" <rjw@rjwysocki.net> wrote:

> On Thursday, February 12, 2015 10:10:30 PM KY Srinivasan wrote:
> 
> [cut]

yay!

> > > > > >
> > > > > > This issue was first discovered by Andy Whitcroft:
> > > > > > https://lkml.org/lkml/2014/3/14/451
> > > > > > I had sent patches based on Andy's analysis that did not affect
> > > > > > the users of the kernel hot-add memory APIs:
> > > > > > https://lkml.org/lkml/2014/12/2/662
> > > > > >
> > > > > > This patch puts the burden where it needs to be and can address
> > > > > > the issue
> > > > > for all clients.
> > > > >
> > > > > That seems to mean that this series is not needed.  Is that correct?
> > > >
> > > > This patch was never committed upstream and so the issue still is there.
> > > 
> > > Well, I'm not sure what to do now to be honest.
> > > 
> > > Is this series regarded as the right way to address the problem that
> > > everybody is comfortable with?  Or is it still under discussion?
> > 
> > We need to solve this problem and that is not under discussion. I also believe this problem
> > needs to be solved in a way that addresses the problem where it belongs - not in the users of
> > the hot_add API. Both my solution and the one proposed by David https://lkml.org/lkml/2015/2/12/57
> > address this issue. You can select either patch and check it in. I just want the issue addressed and I am not
> > married to the solution I proposed.
> 
> OK, thanks!
> 
> So having looked at both your patch and the David's one I think that
> the Andrew's tree is appropriate for any of them.
> 
> Andrew?

OK, I'll wake up and take a look.  Hopefully as 3.21 material but I
need to to back and reread everything.  Is it more urgent than that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
