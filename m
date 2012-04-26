Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 19AD06B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:22:35 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so85071wgb.26
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:22:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F99C980.3030801@parallels.com>
References: <1335475463-25167-1-git-send-email-glommer@parallels.com>
	<1335475463-25167-3-git-send-email-glommer@parallels.com>
	<20120426213916.GD27486@google.com>
	<4F99C50D.6070503@parallels.com>
	<20120426221324.GE27486@google.com>
	<4F99C980.3030801@parallels.com>
Date: Thu, 26 Apr 2012 15:22:33 -0700
Message-ID: <CAOS58YOKUq7GTTZRcw19dth+HgThoNTEcqBKeNO0ftB4rFJ97A@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] decrement static keys on real destroy time
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, netdev@vger.kernel.org, Li Zefan <lizefan@huawei.com>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, devel@openvz.org

Hello,

On Thu, Apr 26, 2012 at 3:17 PM, Glauber Costa <glommer@parallels.com> wrote:
>
>> No, what I mean is that why can't you do about the same mutexed
>> activated inside static_key API function instead of requiring every
>> user to worry about the function returning asynchronously.
>> ie. synchronize inside static_key API instead of in the callers.
>>
>
> Like this?

Yeah, something like that.  If keeping the inc operation a single
atomic op is important for performance or whatever reasons, you can
play some trick with large negative bias value while activation is
going on and use atomic_add_return() to determine both whether it's
the first incrementer and someone else is in the process of
activating.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
