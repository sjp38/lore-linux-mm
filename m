Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91C8F6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 12:20:07 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k76-v6so267415lfg.9
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 09:20:07 -0700 (PDT)
Received: from mx1.yrkesakademin.fi (mx1.yrkesakademin.fi. [85.134.45.194])
        by mx.google.com with ESMTPS id s23si380250ljs.14.2018.04.19.09.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 09:20:05 -0700 (PDT)
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
References: <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home> <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home> <20180416161911.GA2341@sasha-vm>
 <7d5de770-aee7-ef71-3582-5354c38fc176@mageia.org>
 <20180419135943.GC16862@kroah.com>
 <6425991f-7d7f-b1f9-ba37-3212a01ad6cf@mageia.org>
 <20180419150954.GC2341@sasha-vm>
From: Thomas Backlund <tmb@mageia.org>
Message-ID: <0714b77f-d659-3c8b-8225-f435d7c08ae7@mageia.org>
Date: Thu, 19 Apr 2018 19:20:03 +0300
MIME-Version: 1.0
In-Reply-To: <20180419150954.GC2341@sasha-vm>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>, Thomas Backlund <tmb@mageia.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

Den 19.04.2018 kl. 18:09, skrev Sasha Levin:
> On Thu, Apr 19, 2018 at 06:04:26PM +0300, Thomas Backlund wrote:
>> Den 19.04.2018 kl. 16:59, skrev Greg KH:
>>> Anyway, we are trying not to do this, but it does, and will,
>>> occasionally happen.  Look, we just did that for one platform for
>>> 4.9.94!  And the key to all of this is good testing, which we are now
>>> doing, and hopefully you are also doing as well.
>>
>> Yeah, but having to test stuff with known breakages is no fun, so we
>> try to avoid that
> 
> Known breakages are easier to deal with than unknown ones :)


well, if a system worked before the update, but not after...
Guess wich one we want...


> 
> I think that that "bug compatability" is basically a policy on *which*
> regressions you'll see vs *if* you'll see a regression.
> 


No. Intentionally breaking known working code in a stable branch is 
never ok.

As I said before... something that never worked is not a regression,
but breaking a previously working setup is...

That goes for security fixes too... there is not much point in a 
security fix, if it basically turns into a local DOS when the system 
stops working...

People will just boot older code and there you have it...


> We'll never pull in a commit that introduces a bug but doesn't fix
> another one, right? So if you have to deal with a regression anyway,
> might as well deal with a regression that is also seen on mainline, so
> that when you upgrade your stable kernel you'll keep the same set of
> regressions to deal with.
> 


Here I actually like the comment Linus posted about API breakage earlier 
in this thread...

<quote>
If you break user workflows, NOTHING ELSE MATTERS.

Even security is secondary to "people don't use the end result,
because it doesn't work for them any more".
</quote>

_This_ same statement should be aknowledged / enforced in stable trees 
too IMHO...

Because this is what will happend...

simple logic... if it does not work, the enduser will boot an earlier 
kernel... missing "all the good fixes" (including security ones) just
because one fix is bad.

For example in this AUTOSEL round there is 161 fixes of wich the enduser
never gets the 160 "supposedly good ones" when one is "bad"...


How is that a "good thing" ?


And trying to tell those that get hit "this will force upstream to fix 
it faster, so you get a working setup in some days/weeks/months..." is
not going to work...


Heh, This even reminds me that this is just as annoying as when MS
started to "bundle monthly security updates" and you get 95% installed
just to realize that the last 5% does not work (or install at all) and
you have to rollback to something working thus missing the needed
security fixes...

Same flawed logic...

Thnakfully we as distro maintainers can avoid some of the breakage for 
our enduses...

--
Thomas
