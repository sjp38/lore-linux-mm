Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 984BD6B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 17:19:47 -0400 (EDT)
Message-ID: <4E4ED366.1090104@genband.com>
Date: Fri, 19 Aug 2011 15:19:34 -0600
From: Chris Friesen <chris.friesen@genband.com>
MIME-Version: 1.0
Subject: Re: running of out memory => kernel crash
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <CAK1hOcN7q=F=UV=aCAsVOYO=Ex34X0tbwLHv9BkYkA=ik7G13w@mail.gmail.com> <1313075625.50520.YahooMailNeo@web111715.mail.gq1.yahoo.com> <201108111938.25836.vda.linux@googlemail.com> <CAG1a4rsO7JDqmYiwyxPrAHdLNbJt+wqymSzU9i1dv5w5C2OFog@mail.gmail.com> <CAK1hOcM5u-zB7fUnR5QVJGBrEnLMhK9Q+EmWBknThga70UQaLw@mail.gmail.com> <CAG1a4rus+VVhhB3ayuDF2pCQDusLekGOAxf33+u_uzxC1yz1MA@mail.gmail.com> <CAF_S4t--+Ufkb2bVrt9e59R=yty5U5Cb=Kt5RbjPjraM_equog@mail.gmail.com>
In-Reply-To: <CAF_S4t--+Ufkb2bVrt9e59R=yty5U5Cb=Kt5RbjPjraM_equog@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bryan Donlan <bdonlan@gmail.com>
Cc: Pavel Ivanov <paivanof@gmail.com>, Denys Vlasenko <vda.linux@googlemail.com>, Mahmood Naderan <nt_mahmood@yahoo.com>, David Rientjes <rientjes@google.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/19/2011 01:29 PM, Bryan Donlan wrote:
> On Thu, Aug 18, 2011 at 10:26, Pavel Ivanov<paivanof@gmail.com>  wrote:

>> Could you elaborate on this? We have a completely unusable server
>> which can be revived only by hard power cycling (administrators won't
>> be able to log in because sshd and shell will fall victims of the same
>> unending disk reading). And as an alternative we can kill some process
>> and at least allow administrator to log in and check if something else
>> can be done to make server feel better. Why is it worse?
>>
>> I understand that it could be very hard to detect such situation but
>> at least it's worth trying I think.
>
> Deciding when to call the server unusable is a policy decision that
> the kernel can't make very easily on its own; the point when the
> system is considered unusable may be different depending on workload.
> You could create a userspace daemon, however, that mlockall()s, then
> monitors memory usage, load average, etc and kills processes when
> things start to go south. You could also use the memory resource
> cgroup controller to set hard limits on memory usage.

Indeed.  From the point of view of the OS, it's running everything on 
the system without a problem.  It's deep into swap, but it's running.

If there are application requirements on grade-of-service, it's up to 
the application to check whether those are being met and if not to do 
something about it.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
