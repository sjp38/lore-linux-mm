Date: Sun, 3 Aug 2003 15:44:59 +0800
From: Eugene Teo <eugene.teo@eugeneteo.net>
Subject: Re: 2.6.0-test2-mm3
Message-ID: <20030803074459.GB663@eugeneteo.net>
Reply-To: Eugene Teo <eugene.teo@eugeneteo.net>
References: <20030802152202.7d5a6ad1.akpm@osdl.org> <20030803070542.GF10284@lorien.emufarm.org> <20030803071520.GA1044@eugeneteo.net> <20030803072838.GG10284@lorien.emufarm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030803072838.GG10284@lorien.emufarm.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Danek Duvall <duvall@emufarm.org>, Eugene Teo <eugene.teo@eugeneteo.net>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

<quote sender="Danek Duvall">
> On Sun, Aug 03, 2003 at 03:15:20PM +0800, Eugene Teo wrote:
> 
> > does your logs say that network is not functioning, yet syslog seems
> > to be running all these while? did you use a radeontool to "off" your
> > lcd screen? fyi, I am using Fujitsu E-7010.
> 
> There's nothing in my logs at all, so there's no way to tell what, if
> anything, survived the resume.  I'm not using radeontool; I hadn't even
> been aware of it until now.

check /var/log/message, did you get something like:

Aug  3 07:01:22 amaryllis -- MARK --
Aug  3 07:21:22 amaryllis -- MARK --
Aug  3 07:41:22 amaryllis -- MARK --
Aug  3 08:01:22 amaryllis -- MARK --
Aug  3 08:21:22 amaryllis -- MARK --
Aug  3 08:41:22 amaryllis -- MARK --
Aug  3 09:01:22 amaryllis -- MARK --
Aug  3 09:21:22 amaryllis -- MARK --
Aug  3 09:41:22 amaryllis -- MARK -- 

it shows that even though the laptop "freezes", the
laptop is still functioning. i just can't bring it
back to life or resume it. network is down, evident
from my getmail logs.

radeontool is simply a userspace tool that turns off
your lcd backlight.

Eugene

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
