Message-ID: <3C51B329.5080409@ca.metsci.com>
Date: Fri, 25 Jan 2002 11:34:01 -0800
From: "Neil J. Fergusson" <fergusson@ca.metsci.com>
MIME-Version: 1.0
Subject: Re: memory leakage detection tools
References: <Pine.GSU.4.30_heb2.09.0201191805440.24506-100000@actcom.co.il>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kplug-newbie@kernel-panic.org
Cc: kplug-lpsg@kernel-panic.org, mehul radheshyam choube <mehulchoube_lpsg@rediffmail.com>, linux-mm@kvack.org, plug-mail@codio.net, plug-mail@plug.org.in
List-ID: <linux-mm.kvack.org>

Try "Bounds Checking", a GPL-ed (I believe) program.

  - Neil Fergusson


guy keren wrote:

> On 19 Jan 2002, mehul radheshyam choube wrote:
> 
> 
>>    i am writing c program which uses lot of pointer variables.
>>
> [...snip...]
> 
>>    but now i want to check whether there is any memory leakage.can
>>    anybody suggest me any free tool for this.
>>
> 
> i've conducted some "research" (you might call it) for development tools
> for linux (including malloc debugging libraries) for a lecture i carried
> in our local linux club - look at the slides:
> http://linuxclub.il.eu.org/newcomers/lectures/6/ide.html
> 
> and specifically under 'Debug libraries'.
> 
> hope this helps,
> --
> guy
> 
> "For world domination - press 1,
>  or dial 0, and please hold, for the creator." -- nob o. dy
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
