Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F34D46B0022
	for <linux-mm@kvack.org>; Mon, 16 May 2011 19:11:50 -0400 (EDT)
Received: by pzk4 with SMTP id 4so3266734pzk.14
        for <linux-mm@kvack.org>; Mon, 16 May 2011 16:11:49 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for task comm references
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
 <1305580757-13175-4-git-send-email-john.stultz@linaro.org>
 <op.vvlfaobx3l0zgt@mnazarewicz-glaptop>
 <alpine.DEB.2.00.1105161431550.4353@chino.kir.corp.google.com>
 <1305587090.2503.42.camel@Joe-Laptop>
Date: Tue, 17 May 2011 01:11:45 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vvlj1vad3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1305587090.2503.42.camel@Joe-Laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andy Whitcroft <apw@canonical.com>, Joe Perches <joe@perches.com>
Cc: LKML <linux-kernel@vger.kernel.org>, John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 17 May 2011 01:04:50 +0200, Joe Perches <joe@perches.com> wrote:

> On Mon, 2011-05-16 at 14:34 -0700, David Rientjes wrote:
>> On Mon, 16 May 2011, Michal Nazarewicz wrote:
>> > > Now that accessing current->comm needs to be protected,
>> > > +# check for current->comm usage
>> > > +		if ($line =~ /\b(?:current|task|tsk|t)\s*->\s*comm\b/) {
>> > Not a checkpatch.pl expert but as far as I'm concerned, that looks  
>> reasonable.
>
> I think the only checkpatch expert is Andy Whitcroft.
>
> You don't need (?: just (

Yep, it's a micro-optimisation though.

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
