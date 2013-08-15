Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id C11456B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 21:51:31 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id c11so119834qcv.13
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 18:51:30 -0700 (PDT)
Date: Wed, 14 Aug 2013 21:51:23 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
Message-ID: <20130815015123.GA3079@htj.dyndns.org>
References: <20130814182342.GG28628@htj.dyndns.org>
 <520BDD2F.2060909@gmail.com>
 <20130814195541.GH28628@htj.dyndns.org>
 <520BE891.8090004@gmail.com>
 <20130814203538.GK28628@htj.dyndns.org>
 <520BF3E3.5030006@gmail.com>
 <20130814213637.GO28628@htj.dyndns.org>
 <520C2A06.5020007@gmail.com>
 <20130815012133.GQ28628@htj.dyndns.org>
 <520C3104.6000802@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520C3104.6000802@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Tang Chen <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Wed, Aug 14, 2013 at 09:38:12PM -0400, KOSAKI Motohiro wrote:
> As you think makes no sense, I also think your position makes no sense. So, please
> stop emotional word. That doesn't help discussion progress.

Would you then please stop making nonsense assertions like "the
fundamental rule here is to crash"?  You could have started the whole
thread with "I'm not sure about the failure mode, it can be better to
hard fail because ..." and we could have debated on the details.
Instead I now have to break the nonsense assertion.  Of course the
tension is way higher.

> If the user was you, I agree. But I know the users don't react so.

Yeah, users react super well to machines failing boot without any way
to know what's going on.  How is a good idea?

> Again, there is no perfect solution if an admin is true stupid. We can just
> suggest "you are wrong, not kernel", but no more further. I'm sure just kernel
> logging doesn't help because they don't read it and they say no body read such

There are things like automated reporting.  The system is trying to
use hotplug, right?  It would have associated tools to do that, won't
it?  If you want to support it, build sensible tools and conventions
around it and given how specialized / highend the whole thing is, it
shouldn't be hard either.

> plenty and for developer messages. I may accept any strong notification, but,
> still, I don't think it's worth. Only sane way is, an admin realize their mistake
> and fix themselves.

Yes, we'll show them who's the boss.  No, this is not how things are
done in kernel.  We don't crash to give admins a lesson.  Do you even
realize that this isn't completely deterministic?  The machine might
boot fine one time and fail the next time.  What lesson would that
teach the admin?  Stay away from linux?

> Huh? no fallback mean no additional code. I can't imagine no code makes runtime overhead.

What fallback are you talking about?  You need to report hotpluggable
node somehow anyway.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
