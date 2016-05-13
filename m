Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21D146B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:10:53 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id m64so70224884lfd.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:10:53 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz28.laposte.net. [194.117.213.103])
        by mx.google.com with ESMTPS id ez7si22595133wjd.197.2016.05.13.08.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:10:51 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout016 (Postfix) with ESMTP id 898E4113CB0
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:10:51 +0200 (CEST)
Received: from lpn-prd-vrin002 (lpn-prd-vrin002.laposte [10.128.63.3])
	by lpn-prd-vrout016 (Postfix) with ESMTP id 83D6F113BD2
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:10:51 +0200 (CEST)
Received: from lpn-prd-vrin002 (localhost [127.0.0.1])
	by lpn-prd-vrin002 (Postfix) with ESMTP id 7218B5BF003
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:10:51 +0200 (CEST)
Message-ID: <5735EE7A.4010600@laposte.net>
Date: Fri, 13 May 2016 17:10:50 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net> <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr> <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz> <5735CAE5.5010104@laposte.net> <20160513145101.GS20141@dhcp22.suse.cz>
In-Reply-To: <20160513145101.GS20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Michal,

On 05/13/2016 04:51 PM, Michal Hocko wrote:
> 
> The default should cover the most use cases. If you can prove that the
> vast majority of embeded systems are different and would _benefit_ from
> a different default I wouldn't be opposed to change the default there.

I'm unsure of a way to prove that.
I mean, what was the way used to prove that "the most use cases" is ok with overcommit=guess? It seems it was an empirical thing.

Also note that this is not changing any default.
It is merely adding the option to change the initial mode without relying on the userspace.

>> :-)
>> I see, so basically it is a sort of workaround.
> 
> No it is not a workaround. It is just serving the purpose of the
> operating system. The allow using the HW as much as possible to the
> existing userspace. You cannot expect userspace will change just because
> we do not like the overcommiting the memory with all the fallouts.

I agree, but that is one of the things that is fuzzy.
My understanding is that there was a time when there was no overcommit at all.
If that's the case, understanding why overcommit was introduced would be helpful.

>> Anyway, in the embedded world the memory and system requirements are
>> usually controlled.
> 
> OK, but even when it is controlled does it suffer in any way just
> because of the default setting? Do you see OOM killer invocation
> when the overcommit would prevent from that?

I'll have to check those LTP tests again, I'll come back to this question later then.

>> Would you agree to the option if it was dependent on
>> CONFIG_EMBEDDED? Or if it was a hidden option?
>> (I understand though that it wouldn't affect the size of config space)
> 
> It could be done in the code and make the default depending on the
> existing config. But first try to think about what would be an advantage
> of such a change.

:) Well, right now I'm just trying to understand the history of this setting, because it is not obvious why it is good.

>>
>> Well, mostly the history of this setting, why it was introduced, etc.
>> more or less what we are discussing here.  Because honestly, killing
>> random processes does not seems like a straightforward idea, ie: it is
>> not obvious.  Like I was saying, without context, such behaviour looks
>> a bit crazy.
> 
> But we are not killing a random process. The semantic is quite clear. We
> are trying to kill the biggest memory hog and if it has some children
> try to sacrifice them to save as much work as possible.

Ok.
That's not the impression I have considering in my case it killed terminals and editors, but I'll try to get some examples.

>>
>> Well, a more urgent problem would be that in that case
>> overcommit=never is not really well tested.
> 
> This is a problem of the userspace and am really skeptical that a change
> in default would make any existing bugs going away. It is more likely we
> will see reports that ENOMEM has been returned even though there is
> pletny of memory available.
> 

Again, I did not propose to change the default.
The idea was just to allow setting the initial overcommit mode in the kernel without relying on the userspace.
(also beause it is still not yet clear why it is left to the userspace)

>>
>> Well, it's hard to report, since it is essentially the result of a
>> dynamic system.
> 
> Each oom killer invocation will provide a detailed report which will
> help MM developers to debug what went wrong and why.
> 

Ok.

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
