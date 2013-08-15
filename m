Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 37B176B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 21:38:17 -0400 (EDT)
Received: by mail-vb0-f54.google.com with SMTP id q14so148430vbe.41
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 18:38:16 -0700 (PDT)
Message-ID: <520C3104.6000802@gmail.com>
Date: Wed, 14 Aug 2013 21:38:12 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <20130812180758.GA8288@mtj.dyndns.org> <520BC950.1030806@gmail.com> <20130814182342.GG28628@htj.dyndns.org> <520BDD2F.2060909@gmail.com> <20130814195541.GH28628@htj.dyndns.org> <520BE891.8090004@gmail.com> <20130814203538.GK28628@htj.dyndns.org> <520BF3E3.5030006@gmail.com> <20130814213637.GO28628@htj.dyndns.org> <520C2A06.5020007@gmail.com> <20130815012133.GQ28628@htj.dyndns.org>
In-Reply-To: <20130815012133.GQ28628@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Tang Chen <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

(8/14/13 9:21 PM), Tejun Heo wrote:
> Hello, KOSAKI.
>
> On Wed, Aug 14, 2013 at 09:08:22PM -0400, KOSAKI Motohiro wrote:
> ...
>> a fallback. Bogus and misguided fallback give a user false relief and they don't
>> notice their mistake quickly. The answer is, there is the fundamental rule.
>> We always said, "measure your system carefully, and setting option carefully too".
>> I have no seen any reason to make exception in this case.
>
> Ugh... that is one stupid rule.  Sure, there are cases when those
> aren't avoidable but sticking to that when there are better ways to do
> it is stupid.  Why would you make it finicky when you don't have to?
> That makes no sense.

As you think makes no sense, I also think your position makes no sense. So, please
stop emotional word. That doesn't help discussion progress.


>> Secondly, memory hotplug is now maintained I and kamezawa-san. Then, I much likely
>> have a chance to get a hotplug related bug report. For protecting my life, I don't
>> want get a false bug claim. Then, I wouldn't like to aim incomplete fallback. When
>> an admin makes mistake, they should shoot their foot, not me!
>
> Dude, it's not cool to cause users' machine to fail boot because you
> want bug report.  You don't do that.  There are other ways to achieve
> that.  When the kernel can't make all hotpluggable nodes hotpluggable
> (I mean, it's not necessarily node aligned to begin with), generate
> warning and a debug dump with appropriate log levels.

If the user was you, I agree. But I know the users don't react so.

> If you think causing users' machine fail boot indetermistically is
> acceptable, you really shouldn't be maintaining anything.  What is
> this?  Are you nuts?

Again, there is no perfect solution if an admin is true stupid. We can just
suggest "you are wrong, not kernel", but no more further. I'm sure just kernel
logging doesn't help because they don't read it and they say no body read such
plenty and for developer messages. I may accept any strong notification, but,
still, I don't think it's worth. Only sane way is, an admin realize their mistake
and fix themselves.


>> Thirdly, I haven't insist to aim verbose and kind messages as last breath. It much
>> likely help users.
>
> I have no idea what you're trying to say.

I meant, "which is verbose" makes no sense. I don't take it.


>> Last, we are now discussing hotplug feature. Then, we can assume hotpluggable machine.
>> They have a hotplug interface in farmware by definition. So, you need to aim a magic.
>
> This is by no way magic.  It's a band-aid feature which aims to
> achieve some portion of functionality with minimal impact on the rest
> of code / runtime overhead.  If you wanna nack the whole thing, be my
> guest.

Huh? no fallback mean no additional code. I can't imagine no code makes runtime overhead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
